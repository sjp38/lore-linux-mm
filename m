Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id C16BF6B004A
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 20:25:56 -0400 (EDT)
Message-ID: <4F7F8992.4050004@tilera.com>
Date: Fri, 6 Apr 2012 20:25:54 -0400
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] hugetlb: fix race condition in hugetlb_fault()
References: <201203302018.q2UKIFH5020745@farm-0012.internal.tilera.com> <CAJd=RBCoLNB+iRX1shKGAwSbE8PsZXyk9e3inPTREcm2kk3nXA@mail.gmail.com> <201203311339.q2VDdJMD006254@farm-0012.internal.tilera.com> <CAJd=RBBWx7uZcw=_oA06RVunPAGeFcJ7LY=RwFCyB_BreJb_kg@mail.gmail.com> <4F7887A5.3060700@tilera.com> <20120406152305.59408e35.akpm@linux-foundation.org> <alpine.LSU.2.00.1204061601370.3637@eggly.anvils> <20120406162618.3307a9bd.akpm@linux-foundation.org> <alpine.LSU.2.00.1204061631160.3820@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1204061631160.3820@eggly.anvils>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 4/6/2012 7:35 PM, Hugh Dickins wrote:
> On Fri, 6 Apr 2012, Andrew Morton wrote:
>> On Fri, 6 Apr 2012 16:10:13 -0700 (PDT)
>> Hugh Dickins <hughd@google.com> wrote:
>>> The resulting patch is okay; but let's reassure Chris that his
>>> original patch was better, before he conceded to make the get_page
>>> and put_page unconditional, and added unnecessary detail of the race.
>>>
>> Yes, the v1 patch was better.  No reason was given for changing it?
> I think Chris was aiming to be a model citizen, and followed review
> suggestions that he would actually have done better to resist.

Yes, exactly.  I figure if I'm submitting patches to mm, I should defer to
suggestions from someone like Hillf who has committed a lot more of them
than I have. :-)   Arguably the unconditional version is simpler at the
source code level in any case, and I figure more is usually better when it
comes to documenting race conditions, so it didn't seem necessary to push
back.  Frankly I'm happy to keep my sign-off on either version of the patch
and defer to Andrew or whomever as to which one gets taken.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
