Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 9119F6B0029
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 20:10:55 -0500 (EST)
Message-ID: <5111AC7D.9070505@cn.fujitsu.com>
Date: Wed, 06 Feb 2013 09:06:05 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] mm: rename confusing function names
References: <51113CE3.5090000@gmail.com> <20130205192640.GC6481@cmpxchg.org> <20130205141332.04fcceac.akpm@linux-foundation.org>
In-Reply-To: <20130205141332.04fcceac.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Zhang Yanfei <zhangyanfei.yes@gmail.com>, Linux MM <linux-mm@kvack.org>, mgorman@suse.de, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, m.szyprowski@samsung.com, linux-kernel@vger.kernel.org

=E4=BA=8E 2013=E5=B9=B402=E6=9C=8806=E6=97=A5 06:13, Andrew Morton =E5=86=
=99=E9=81=93:
> On Tue, 5 Feb 2013 14:26:40 -0500
> Johannes Weiner <hannes@cmpxchg.org> wrote:
>=20
>> On Wed, Feb 06, 2013 at 01:09:55AM +0800, Zhang Yanfei wrote:
>>> Function nr=5Ffree=5Fzone=5Fpages, nr=5Ffree=5Fbuffer=5Fpages and nr=5F=
free=5Fpagecache=5Fpages
>>> are horribly badly named, they count present=5Fpages - pages=5Fhigh wit=
hin zones
>>> instead of free pages, so why not rename them to reasonable names, not =
cofusing
>>> people.
>>>
>>> patch2 and patch3 are based on patch1. So please apply patch1 first.
>>>
>>> Zhang Yanfei (3):
>>>   mm: rename nr=5Ffree=5Fzone=5Fpages to nr=5Ffree=5Fzone=5Fhigh=5Fpages
>>>   mm: rename nr=5Ffree=5Fbuffer=5Fpages to nr=5Ffree=5Fbuffer=5Fhigh=5F=
pages
>>>   mm: rename nr=5Ffree=5Fpagecache=5Fpages to nr=5Ffree=5Fpagecache=5Fh=
igh=5Fpages
>>
>> I don't feel that this is an improvement.
>>
>> As you said, the "free" is already misleading, because those pages
>> might all be allocated.  "High" makes me think not just of highmem,
>> but drug abuse in general.
>>
>> nr=5Favailable=5F*=5Fpages?  I don't know, but if we go through with all
>> that churn, it had better improve something.
>=20
> Yes, those names are ghastly.
>=20
> Here's an idea: accurately document the functions with code comments.=20
> Once this is done, that documentation may well suggest a good name ;)
>=20

As Johannes said, free is already misleading, so I think we should
rename "free" at first. to "available"? I think it is ok.

"high" here means those pages are above high watermark of a zone,
not highmem or something else.

So could I rename the functions to the names like
nr=5Favailable=5Fbuffer=5Fhigh=5Fpages
And accurately document them with code comments just as you suggested.

is this ok?

>=20
> While we're there, please note that nr=5Ffree=5Fbuffer=5Fpages() has a *l=
ot*
> of callers.  Generally it's code which is trying to work out what is an
> appropriate size for preallocated caching space, lookup tables, etc.=20
>=20
> That's a rather hopeless objective, given memory hotplug, mlock, etc.=20
> But please do take a look at *why* these callers are calling
> nr=5Ffree=5Fbuffer=5Fpages() and let's ensure that both the implementation
> and name are appropriate to their requirements.

Yeah, it does have a lot callers and I think some of the callers are
misusing the function from the comments. They always want to call the
function to get lowmem pages.

Thanks
Zhang Yanfei


=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
