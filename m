Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 6E5366B002B
	for <linux-mm@kvack.org>; Fri, 14 Dec 2012 14:44:42 -0500 (EST)
From: Satoru Moriya <satoru.moriya@hds.com>
Subject: RE: [patch 2/8] mm: vmscan: disregard swappiness shortly before
 going OOM
Date: Fri, 14 Dec 2012 19:44:30 +0000
Message-ID: <8631DC5930FA9E468F04F3FD3A5D007214AD7315@USINDEM103.corp.hds.com>
References: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org>
 <1355348620-9382-3-git-send-email-hannes@cmpxchg.org>
 <20121213103420.GW1009@suse.de> <20121213152959.GE21644@dhcp22.suse.cz>
 <20121213160521.GG21644@dhcp22.suse.cz>
 <8631DC5930FA9E468F04F3FD3A5D007214AD2FA2@USINDEM103.corp.hds.com>
 <20121214045030.GE6317@cmpxchg.org> <20121214083738.GA6898@dhcp22.suse.cz>
In-Reply-To: <20121214083738.GA6898@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 12/14/2012 03:37 AM, Michal Hocko wrote:
> On Thu 13-12-12 23:50:30, Johannes Weiner wrote:
>> On Thu, Dec 13, 2012 at 10:25:43PM +0000, Satoru Moriya wrote:
>>>
>>> I introduced swappiness check here with fe35004f because, in some=20
>>> cases, we prefer OOM to swap out pages to detect problems as soon as=20
>>> possible. Basically, we design the system not to swap out and so if=20
>>> it causes swapping, something goes wrong.
>>
>> I might be missing something terribly obvious, but... why do you add=20
>> swap space to the system in the first place?  Or in case of cgroups,=20
>> why not set the memsw limit equal to the memory limit?
>=20
> I can answer the later. Because memsw comes with its price and=20
> swappiness is much cheaper. On the other hand it makes sense that
> swappiness=3D=3D0 doesn't swap at all. Or do you think we should get back=
=20
> to _almost_ doesn't swap at all?
>=20

Right. One of the reason is what Michal described above and another
reason that I thought is softlimit. softlimit reclaim always works
with priority=3D0. Therefore, if we set softlimit to one memcg without
swappiness=3D0, the kernel scans both anonymous and filebacked pages
during soft limit reclaim for the memcg and reclaims them.

Regards,
Satoru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
