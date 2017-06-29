Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A37EC6B0292
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 14:02:54 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b184so3443475wme.14
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 11:02:54 -0700 (PDT)
Received: from mail-wr0-x22b.google.com (mail-wr0-x22b.google.com. [2a00:1450:400c:c0c::22b])
        by mx.google.com with ESMTPS id o2si1741031wmb.113.2017.06.29.11.02.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 11:02:52 -0700 (PDT)
Received: by mail-wr0-x22b.google.com with SMTP id c11so193470724wrc.3
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 11:02:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAA25o9RL6ntbL9+ae11_AbGSZ7MNTNZv8yEW4jvZdMa-en+8ag@mail.gmail.com>
References: <CAA25o9T1WmkWJn1LA-vS=W_Qu8pBw3rfMtTreLNu8fLuZjTDsw@mail.gmail.com>
 <20170627071104.GB28078@dhcp22.suse.cz> <CAA25o9T1q9gWzb0BeXY3mvLOth-ow=yjVuwD9ct5f1giBWo=XQ@mail.gmail.com>
 <CAA25o9TUkHd9w+DNBdH_4w6LTEEb+Q6QAycHcqx-z3mwh+G=kA@mail.gmail.com>
 <20170627155035.GA20189@dhcp22.suse.cz> <CAA25o9RL6ntbL9+ae11_AbGSZ7MNTNZv8yEW4jvZdMa-en+8ag@mail.gmail.com>
From: Luigi Semenzato <semenzato@google.com>
Date: Thu, 29 Jun 2017 11:02:50 -0700
Message-ID: <CAA25o9RAkWxBjBPepb8=isH2YxLfbZ8b3oWJYXbyYCooUFkMAQ@mail.gmail.com>
Subject: Re: OOM kills with lots of free swap
Content-Type: multipart/mixed; boundary="001a113c2ba4f4fdd105531d1b73"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

--001a113c2ba4f4fdd105531d1b73
Content-Type: text/plain; charset="UTF-8"

Just to make sure I wasn't dreaming this, I searched and found some
old logs (5 years ago, kernel 3.4) when I was trying to debug the
problem.  Thanks!

1999-12-31T17:00:07.697712-08:00 localhost kernel: [    0.000000]
Linux version 3.4.0 (semenzato@luigi.mtv.corp.google.com) (gcc version
4.6.x-google 20120301 (prerelease) (gcc-4.6.3_cos_gg_2a32ae6) ) #31
SMP Tue Nov 27 16:44:46 PST 2012
1999-12-31T17:00:07.698992-08:00 localhost kernel: [    0.000000] CPU:
ARMv7 Processor [410fc0f4] revision 4 (ARMv7), cr=10c5387d


2012-11-28T10:21:56.879950-08:00 localhost kernel: [ 1652.710107] hog
invoked oom-killer: gfp_mask=0x200da, order=0, oom_adj=15,
oom_score_adj=1000
2012-11-28T10:21:56.879993-08:00 localhost kernel: [ 1652.710137]
[<800154ac>] (unwind_backtrace+0x0/0xec) from [<804ebcac>]
(dump_stack+0x20/0x24)
2012-11-28T10:21:56.913206-08:00 localhost kernel: [ 1652.710156]
[<804ebcac>] (dump_stack+0x20/0x24) from [<800b91b4>]
(dump_header.isra.10+0x7c/0x174)
2012-11-28T10:21:56.913242-08:00 localhost kernel: [ 1652.710173]
[<800b91b4>] (dump_header.isra.10+0x7c/0x174) from [<800b93f0>]
(oom_kill_process.part.13.constprop.14+0x4c/0x20c)
2012-11-28T10:21:56.913252-08:00 localhost kernel: [ 1652.710187]
[<800b93f0>] (oom_kill_process.part.13.constprop.14+0x4c/0x20c) from
[<800b9a00>] (out_of_memory+0x2dc/0x38c)
2012-11-28T10:21:56.913261-08:00 localhost kernel: [ 1652.710201]
[<800b9a00>] (out_of_memory+0x2dc/0x38c) from [<800bccf4>]
(__alloc_pages_nodemask+0x6b8/0x8a0)
2012-11-28T10:21:56.913270-08:00 localhost kernel: [ 1652.710216]
[<800bccf4>] (__alloc_pages_nodemask+0x6b8/0x8a0) from [<800e44e0>]
(read_swap_cache_async+0x54/0x11c)
2012-11-28T10:21:56.913278-08:00 localhost kernel: [ 1652.710233]
[<800e44e0>] (read_swap_cache_async+0x54/0x11c) from [<800e460c>]
(swapin_readahead+0x64/0x9c)
2012-11-28T10:21:56.913288-08:00 localhost kernel: [ 1652.710249]
[<800e460c>] (swapin_readahead+0x64/0x9c) from [<800d6fcc>]
(handle_pte_fault+0x2d8/0x668)
2012-11-28T10:21:56.913296-08:00 localhost kernel: [ 1652.710265]
[<800d6fcc>] (handle_pte_fault+0x2d8/0x668) from [<800d7420>]
(handle_mm_fault+0xc4/0xdc)
2012-11-28T10:21:56.913314-08:00 localhost kernel: [ 1652.710281]
[<800d7420>] (handle_mm_fault+0xc4/0xdc) from [<8001b080>]
(do_page_fault+0x114/0x354)
2012-11-28T10:21:56.913324-08:00 localhost kernel: [ 1652.710296]
[<8001b080>] (do_page_fault+0x114/0x354) from [<800083d8>]
(do_DataAbort+0x44/0xa8)
2012-11-28T10:21:56.913332-08:00 localhost kernel: [ 1652.710309]
[<800083d8>] (do_DataAbort+0x44/0xa8) from [<8000dc78>]
(__dabt_usr+0x38/0x40)
2012-11-28T10:21:56.913338-08:00 localhost kernel: [ 1652.710319]
Exception stack(0xed97bfb0 to 0xed97bff8)
2012-11-28T10:21:56.913344-08:00 localhost kernel: [ 1652.710328]
bfa0:                                     00000004 76682008 7673d303
7673d303
2012-11-28T10:21:56.913351-08:00 localhost kernel: [ 1652.710338]
bfc0: 76fa2f8c 76da29a1 76f997f1 7eaac518 00000000 00000000 76fa2f8c
00000000
2012-11-28T10:21:56.913358-08:00 localhost kernel: [ 1652.710349]
bfe0: 00000000 7eaac518 76f99abd 76f99ad8 00000030 ffffffff
2012-11-28T10:21:56.913363-08:00 localhost kernel: [ 1652.710358] Mem-info:
2012-11-28T10:21:56.913369-08:00 localhost kernel: [ 1652.710366]
Normal per-cpu:
2012-11-28T10:21:56.913385-08:00 localhost kernel: [ 1652.710374] CPU
  0: hi:  186, btch:  31 usd:   0
2012-11-28T10:21:56.913392-08:00 localhost kernel: [ 1652.710381] CPU
  1: hi:  186, btch:  31 usd:   0
2012-11-28T10:21:56.913399-08:00 localhost kernel: [ 1652.710389]
HighMem per-cpu:
2012-11-28T10:21:56.913405-08:00 localhost kernel: [ 1652.710396] CPU
  0: hi:   90, btch:  15 usd:   0
2012-11-28T10:21:56.913412-08:00 localhost kernel: [ 1652.710404] CPU
  1: hi:   90, btch:  15 usd:   0
2012-11-28T10:21:56.913419-08:00 localhost kernel: [ 1652.710416]
active_anon:332491 inactive_anon:125198 isolated_anon:2
2012-11-28T10:21:56.913426-08:00 localhost kernel: [ 1652.710420]
active_file:9210 inactive_file:13058 isolated_file:0
2012-11-28T10:21:56.913432-08:00 localhost kernel: [ 1652.710424]
unevictable:0 dirty:3 writeback:0 unstable:0
2012-11-28T10:21:56.913439-08:00 localhost kernel: [ 1652.710427]
free:3497 slab_reclaimable:2097 slab_unreclaimable:2166
2012-11-28T10:21:56.913454-08:00 localhost kernel: [ 1652.710431]
mapped:3349 shmem:8 pagetables:1527 bounce:0
2012-11-28T10:21:56.913467-08:00 localhost kernel: [ 1652.710451]
Normal free:13728kB min:5380kB low:6724kB high:8068kB
active_anon:1244580kB inactive_anon:415092kB active_file:11640kB
inactive_file:27544kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB present:1811520kB mlocked:0kB dirty:0kB
writeback:0kB mapped:2012kB shmem:32kB slab_reclaimable:8388kB
slab_unreclaimable:8664kB kernel_stack:1328kB pagetables:6108kB
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:2641916
all_unreclaimable? no
2012-11-28T10:21:56.913477-08:00 localhost kernel: [ 1652.710475]
lowmem_reserve[]: 0 2095 2095
2012-11-28T10:21:56.913491-08:00 localhost kernel: [ 1652.710502]
HighMem free:260kB min:260kB low:456kB high:656kB active_anon:85384kB
inactive_anon:85700kB active_file:25200kB inactive_file:24688kB
unevictable:0kB isolated(anon):8kB isolated(file):0kB present:268224kB
mlocked:0kB dirty:12kB writeback:0kB mapped:11384kB shmem:0kB
slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB
pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB
pages_scanned:290707 all_unreclaimable? yes
2012-11-28T10:21:56.913500-08:00 localhost kernel: [ 1652.710526]
lowmem_reserve[]: 0 0 0
2012-11-28T10:21:56.913508-08:00 localhost kernel: [ 1652.710545]
Normal: 6*4kB 4*8kB 3*16kB 24*32kB 89*64kB 0*128kB 0*256kB 0*512kB
1*1024kB 1*2048kB 1*4096kB = 13736kB
2012-11-28T10:21:56.913518-08:00 localhost kernel: [ 1652.710597]
HighMem: 61*4kB 4*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB
0*1024kB 0*2048kB 0*4096kB = 276kB
2012-11-28T10:21:56.913535-08:00 localhost kernel: [ 1652.710648]
112925 total pagecache pages
2012-11-28T10:21:56.913541-08:00 localhost kernel: [ 1652.710655]
90646 pages in swap cache
2012-11-28T10:21:56.913548-08:00 localhost kernel: [ 1652.710663] Swap
cache stats: add 733583, delete 642937, find 97864/161478
2012-11-28T10:21:56.913554-08:00 localhost kernel: [ 1652.710671] Free
swap  = 2005380kB
2012-11-28T10:21:56.913559-08:00 localhost kernel: [ 1652.710677]
Total swap = 3028768kB
2012-11-28T10:21:56.913564-08:00 localhost kernel: [ 1652.710683]
luigi_nr_reclaimed 495948
2012-11-28T10:21:56.913570-08:00 localhost kernel: [ 1652.710690]
luigi_nr_reclaims 8820
2012-11-28T10:21:56.913577-08:00 localhost kernel: [ 1652.710696]
luigi_aborted_reclaim 0
2012-11-28T10:21:56.914694-08:00 localhost kernel: [ 1652.710702]
luigi_more_to_do 237
2012-11-28T10:21:56.914704-08:00 localhost kernel: [ 1652.710708]
luigi_direct_reclaims 9086
2012-11-28T10:21:56.914718-08:00 localhost kernel: [ 1652.710714]
luigi_failed_direct_reclaims 98
2012-11-28T10:21:56.914725-08:00 localhost kernel: [ 1652.710721]
luigi_no_progress 1
2012-11-28T10:21:56.914730-08:00 localhost kernel: [ 1652.710727]
luigi_restarts 0
2012-11-28T10:21:56.914734-08:00 localhost kernel: [ 1652.710733]
luigi_should_alloc_retry 97
2012-11-28T10:21:56.914740-08:00 localhost kernel: [ 1652.710739]
luigi_direct_compact 0
2012-11-28T10:21:56.914747-08:00 localhost kernel: [ 1652.710745]
luigi_alloc_failed 111
2012-11-28T10:21:56.914752-08:00 localhost kernel: [ 1652.710751]
luigi_gfp_nofail 0
2012-11-28T10:21:56.914757-08:00 localhost kernel: [ 1652.710757]
luigi_costly_order 97
2012-11-28T10:21:56.914762-08:00 localhost kernel: [ 1652.710763] luigi_repeat 0
2012-11-28T10:21:56.914768-08:00 localhost kernel: [ 1652.710769]
luigi_kswapd_nap 71
2012-11-28T10:21:56.914779-08:00 localhost kernel: [ 1652.710775]
luigi_kswapd_sleep 4
2012-11-28T10:21:56.914785-08:00 localhost kernel: [ 1652.710781]
luigi_kswapd_loop 72
2012-11-28T10:21:56.914791-08:00 localhost kernel: [ 1652.710787]
luigi_kswapd_try_to_sleep 71
2012-11-28T10:21:56.914797-08:00 localhost kernel: [ 1652.710793]
luigi_slowpath 530966
2012-11-28T10:21:56.914803-08:00 localhost kernel: [ 1652.710799]
luigi_wake_all_kswapd 530961
2012-11-28T10:21:56.914808-08:00 localhost kernel: [ 1652.721084]
524288 pages of RAM
2012-11-28T10:21:56.914815-08:00 localhost kernel: [ 1652.721094] 4256
free pages
2012-11-28T10:21:56.914822-08:00 localhost kernel: [ 1652.721100] 7122
reserved pages
2012-11-28T10:21:56.914828-08:00 localhost kernel: [ 1652.721106] 2924
slab pages
2012-11-28T10:21:56.914837-08:00 localhost kernel: [ 1652.721112]
23510 pages shared
2012-11-28T10:21:56.914843-08:00 localhost kernel: [ 1652.721118]
90646 pages swap cached

On Thu, Jun 29, 2017 at 10:46 AM, Luigi Semenzato <semenzato@google.com> wrote:
> Well, my apologies, I haven't been able to reproduce the problem, so
> there's nothing to go on here.
>
> We had a bug (a local patch) which caused this, then I had a bug in my
> test case, so I was confused.  I also have a recollection of this
> happening in older kernels (3.8 I think), but I am not going to go
> back that far since even if the problem exists, we have no evidence it
> happens frequently.
>
> Thanks!
>
>
> On Tue, Jun 27, 2017 at 8:50 AM, Michal Hocko <mhocko@kernel.org> wrote:
>> On Tue 27-06-17 08:22:36, Luigi Semenzato wrote:
>>> (sorry, I forgot to turn off HTML formatting)
>>>
>>> Thank you, I can try this on ToT, although I think that the problem is
>>> not with the OOM killer itself but earlier---i.e. invoking the OOM
>>> killer seems unnecessary and wrong.  Here's the question.
>>>
>>> The general strategy for page allocation seems to be (please correct
>>> me as needed):
>>>
>>> 1. look in the free lists
>>> 2. if that did not succeed, try to reclaim, then try again to allocate
>>> 3. keep trying as long as progress is made (i.e. something was reclaimed)
>>> 4. if no progress was made and no pages were found, invoke the OOM killer.
>>
>> Yes that is the case very broadly speaking. The hard question really is
>> what "no progress" actually means. We use "no pages could be reclaimed"
>> as the indicator. We cannot blow up at the first such instance of
>> course because that could be too early (e.g. data under writeback
>> and many other details). With 4.7+ kernels this is implemented in
>> should_reclaim_retry. Prior to the rework we used to rely on
>> zone_reclaimable which simply checked how many pages we have scanned
>> since the last page has been freed and if that is 6 times the
>> reclaimable memory then we simply give up. It had some issues described
>> in 0a0337e0d1d1 ("mm, oom: rework oom detection").
>>
>>> I'd like to know if that "progress is made" notion is possibly buggy.
>>> Specifically, does it mean "progress is made by this task"?  Is it
>>> possible that resource contention creates a situation where most tasks
>>> in most cases can reclaim and allocate, but one task randomly fails to
>>> make progress?
>>
>> This can happen, alhtough it is quite unlikely. We are trying to
>> throttle allocations but you can hardly fight a consistent badluck ;)
>>
>> In order to see what is going on in your particular case we need an oom
>> report though.
>> --
>> Michal Hocko
>> SUSE Labs

--001a113c2ba4f4fdd105531d1b73
Content-Type: text/plain; charset="US-ASCII"; name="OOM.txt"
Content-Disposition: attachment; filename="OOM.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j4iqkyu30

MjAxMi0xMS0yOFQxMDoyMTo1Ni44Nzk5NTAtMDg6MDAgbG9jYWxob3N0IGtlcm5lbDogWyAxNjUy
LjcxMDEwN10gaG9nIGludm9rZWQgb29tLWtpbGxlcjogZ2ZwX21hc2s9MHgyMDBkYSwgb3JkZXI9
MCwgb29tX2Fkaj0xNSwgb29tX3Njb3JlX2Fkaj0xMDAwCjIwMTItMTEtMjhUMTA6MjE6NTYuODc5
OTkzLTA4OjAwIGxvY2FsaG9zdCBrZXJuZWw6IFsgMTY1Mi43MTAxMzddIFs8ODAwMTU0YWM+XSAo
dW53aW5kX2JhY2t0cmFjZSsweDAvMHhlYykgZnJvbSBbPDgwNGViY2FjPl0gKGR1bXBfc3RhY2sr
MHgyMC8weDI0KQoyMDEyLTExLTI4VDEwOjIxOjU2LjkxMzIwNi0wODowMCBsb2NhbGhvc3Qga2Vy
bmVsOiBbIDE2NTIuNzEwMTU2XSBbPDgwNGViY2FjPl0gKGR1bXBfc3RhY2srMHgyMC8weDI0KSBm
cm9tIFs8ODAwYjkxYjQ+XSAoZHVtcF9oZWFkZXIuaXNyYS4xMCsweDdjLzB4MTc0KQoyMDEyLTEx
LTI4VDEwOjIxOjU2LjkxMzI0Mi0wODowMCBsb2NhbGhvc3Qga2VybmVsOiBbIDE2NTIuNzEwMTcz
XSBbPDgwMGI5MWI0Pl0gKGR1bXBfaGVhZGVyLmlzcmEuMTArMHg3Yy8weDE3NCkgZnJvbSBbPDgw
MGI5M2YwPl0gKG9vbV9raWxsX3Byb2Nlc3MucGFydC4xMy5jb25zdHByb3AuMTQrMHg0Yy8weDIw
YykKMjAxMi0xMS0yOFQxMDoyMTo1Ni45MTMyNTItMDg6MDAgbG9jYWxob3N0IGtlcm5lbDogWyAx
NjUyLjcxMDE4N10gWzw4MDBiOTNmMD5dIChvb21fa2lsbF9wcm9jZXNzLnBhcnQuMTMuY29uc3Rw
cm9wLjE0KzB4NGMvMHgyMGMpIGZyb20gWzw4MDBiOWEwMD5dIChvdXRfb2ZfbWVtb3J5KzB4MmRj
LzB4MzhjKQoyMDEyLTExLTI4VDEwOjIxOjU2LjkxMzI2MS0wODowMCBsb2NhbGhvc3Qga2VybmVs
OiBbIDE2NTIuNzEwMjAxXSBbPDgwMGI5YTAwPl0gKG91dF9vZl9tZW1vcnkrMHgyZGMvMHgzOGMp
IGZyb20gWzw4MDBiY2NmND5dIChfX2FsbG9jX3BhZ2VzX25vZGVtYXNrKzB4NmI4LzB4OGEwKQoy
MDEyLTExLTI4VDEwOjIxOjU2LjkxMzI3MC0wODowMCBsb2NhbGhvc3Qga2VybmVsOiBbIDE2NTIu
NzEwMjE2XSBbPDgwMGJjY2Y0Pl0gKF9fYWxsb2NfcGFnZXNfbm9kZW1hc2srMHg2YjgvMHg4YTAp
IGZyb20gWzw4MDBlNDRlMD5dIChyZWFkX3N3YXBfY2FjaGVfYXN5bmMrMHg1NC8weDExYykKMjAx
Mi0xMS0yOFQxMDoyMTo1Ni45MTMyNzgtMDg6MDAgbG9jYWxob3N0IGtlcm5lbDogWyAxNjUyLjcx
MDIzM10gWzw4MDBlNDRlMD5dIChyZWFkX3N3YXBfY2FjaGVfYXN5bmMrMHg1NC8weDExYykgZnJv
bSBbPDgwMGU0NjBjPl0gKHN3YXBpbl9yZWFkYWhlYWQrMHg2NC8weDljKQoyMDEyLTExLTI4VDEw
OjIxOjU2LjkxMzI4OC0wODowMCBsb2NhbGhvc3Qga2VybmVsOiBbIDE2NTIuNzEwMjQ5XSBbPDgw
MGU0NjBjPl0gKHN3YXBpbl9yZWFkYWhlYWQrMHg2NC8weDljKSBmcm9tIFs8ODAwZDZmY2M+XSAo
aGFuZGxlX3B0ZV9mYXVsdCsweDJkOC8weDY2OCkKMjAxMi0xMS0yOFQxMDoyMTo1Ni45MTMyOTYt
MDg6MDAgbG9jYWxob3N0IGtlcm5lbDogWyAxNjUyLjcxMDI2NV0gWzw4MDBkNmZjYz5dIChoYW5k
bGVfcHRlX2ZhdWx0KzB4MmQ4LzB4NjY4KSBmcm9tIFs8ODAwZDc0MjA+XSAoaGFuZGxlX21tX2Zh
dWx0KzB4YzQvMHhkYykKMjAxMi0xMS0yOFQxMDoyMTo1Ni45MTMzMTQtMDg6MDAgbG9jYWxob3N0
IGtlcm5lbDogWyAxNjUyLjcxMDI4MV0gWzw4MDBkNzQyMD5dIChoYW5kbGVfbW1fZmF1bHQrMHhj
NC8weGRjKSBmcm9tIFs8ODAwMWIwODA+XSAoZG9fcGFnZV9mYXVsdCsweDExNC8weDM1NCkKMjAx
Mi0xMS0yOFQxMDoyMTo1Ni45MTMzMjQtMDg6MDAgbG9jYWxob3N0IGtlcm5lbDogWyAxNjUyLjcx
MDI5Nl0gWzw4MDAxYjA4MD5dIChkb19wYWdlX2ZhdWx0KzB4MTE0LzB4MzU0KSBmcm9tIFs8ODAw
MDgzZDg+XSAoZG9fRGF0YUFib3J0KzB4NDQvMHhhOCkKMjAxMi0xMS0yOFQxMDoyMTo1Ni45MTMz
MzItMDg6MDAgbG9jYWxob3N0IGtlcm5lbDogWyAxNjUyLjcxMDMwOV0gWzw4MDAwODNkOD5dIChk
b19EYXRhQWJvcnQrMHg0NC8weGE4KSBmcm9tIFs8ODAwMGRjNzg+XSAoX19kYWJ0X3VzcisweDM4
LzB4NDApCjIwMTItMTEtMjhUMTA6MjE6NTYuOTEzMzM4LTA4OjAwIGxvY2FsaG9zdCBrZXJuZWw6
IFsgMTY1Mi43MTAzMTldIEV4Y2VwdGlvbiBzdGFjaygweGVkOTdiZmIwIHRvIDB4ZWQ5N2JmZjgp
CjIwMTItMTEtMjhUMTA6MjE6NTYuOTEzMzQ0LTA4OjAwIGxvY2FsaG9zdCBrZXJuZWw6IFsgMTY1
Mi43MTAzMjhdIGJmYTA6ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDAwMDAw
MDA0IDc2NjgyMDA4IDc2NzNkMzAzIDc2NzNkMzAzCjIwMTItMTEtMjhUMTA6MjE6NTYuOTEzMzUx
LTA4OjAwIGxvY2FsaG9zdCBrZXJuZWw6IFsgMTY1Mi43MTAzMzhdIGJmYzA6IDc2ZmEyZjhjIDc2
ZGEyOWExIDc2Zjk5N2YxIDdlYWFjNTE4IDAwMDAwMDAwIDAwMDAwMDAwIDc2ZmEyZjhjIDAwMDAw
MDAwCjIwMTItMTEtMjhUMTA6MjE6NTYuOTEzMzU4LTA4OjAwIGxvY2FsaG9zdCBrZXJuZWw6IFsg
MTY1Mi43MTAzNDldIGJmZTA6IDAwMDAwMDAwIDdlYWFjNTE4IDc2Zjk5YWJkIDc2Zjk5YWQ4IDAw
MDAwMDMwIGZmZmZmZmZmCjIwMTItMTEtMjhUMTA6MjE6NTYuOTEzMzYzLTA4OjAwIGxvY2FsaG9z
dCBrZXJuZWw6IFsgMTY1Mi43MTAzNThdIE1lbS1pbmZvOgoyMDEyLTExLTI4VDEwOjIxOjU2Ljkx
MzM2OS0wODowMCBsb2NhbGhvc3Qga2VybmVsOiBbIDE2NTIuNzEwMzY2XSBOb3JtYWwgcGVyLWNw
dToKMjAxMi0xMS0yOFQxMDoyMTo1Ni45MTMzODUtMDg6MDAgbG9jYWxob3N0IGtlcm5lbDogWyAx
NjUyLjcxMDM3NF0gQ1BVICAgIDA6IGhpOiAgMTg2LCBidGNoOiAgMzEgdXNkOiAgIDAKMjAxMi0x
MS0yOFQxMDoyMTo1Ni45MTMzOTItMDg6MDAgbG9jYWxob3N0IGtlcm5lbDogWyAxNjUyLjcxMDM4
MV0gQ1BVICAgIDE6IGhpOiAgMTg2LCBidGNoOiAgMzEgdXNkOiAgIDAKMjAxMi0xMS0yOFQxMDoy
MTo1Ni45MTMzOTktMDg6MDAgbG9jYWxob3N0IGtlcm5lbDogWyAxNjUyLjcxMDM4OV0gSGlnaE1l
bSBwZXItY3B1OgoyMDEyLTExLTI4VDEwOjIxOjU2LjkxMzQwNS0wODowMCBsb2NhbGhvc3Qga2Vy
bmVsOiBbIDE2NTIuNzEwMzk2XSBDUFUgICAgMDogaGk6ICAgOTAsIGJ0Y2g6ICAxNSB1c2Q6ICAg
MAoyMDEyLTExLTI4VDEwOjIxOjU2LjkxMzQxMi0wODowMCBsb2NhbGhvc3Qga2VybmVsOiBbIDE2
NTIuNzEwNDA0XSBDUFUgICAgMTogaGk6ICAgOTAsIGJ0Y2g6ICAxNSB1c2Q6ICAgMAoyMDEyLTEx
LTI4VDEwOjIxOjU2LjkxMzQxOS0wODowMCBsb2NhbGhvc3Qga2VybmVsOiBbIDE2NTIuNzEwNDE2
XSBhY3RpdmVfYW5vbjozMzI0OTEgaW5hY3RpdmVfYW5vbjoxMjUxOTggaXNvbGF0ZWRfYW5vbjoy
CjIwMTItMTEtMjhUMTA6MjE6NTYuOTEzNDI2LTA4OjAwIGxvY2FsaG9zdCBrZXJuZWw6IFsgMTY1
Mi43MTA0MjBdICBhY3RpdmVfZmlsZTo5MjEwIGluYWN0aXZlX2ZpbGU6MTMwNTggaXNvbGF0ZWRf
ZmlsZTowCjIwMTItMTEtMjhUMTA6MjE6NTYuOTEzNDMyLTA4OjAwIGxvY2FsaG9zdCBrZXJuZWw6
IFsgMTY1Mi43MTA0MjRdICB1bmV2aWN0YWJsZTowIGRpcnR5OjMgd3JpdGViYWNrOjAgdW5zdGFi
bGU6MAoyMDEyLTExLTI4VDEwOjIxOjU2LjkxMzQzOS0wODowMCBsb2NhbGhvc3Qga2VybmVsOiBb
IDE2NTIuNzEwNDI3XSAgZnJlZTozNDk3IHNsYWJfcmVjbGFpbWFibGU6MjA5NyBzbGFiX3VucmVj
bGFpbWFibGU6MjE2NgoyMDEyLTExLTI4VDEwOjIxOjU2LjkxMzQ1NC0wODowMCBsb2NhbGhvc3Qg
a2VybmVsOiBbIDE2NTIuNzEwNDMxXSAgbWFwcGVkOjMzNDkgc2htZW06OCBwYWdldGFibGVzOjE1
MjcgYm91bmNlOjAKMjAxMi0xMS0yOFQxMDoyMTo1Ni45MTM0NjctMDg6MDAgbG9jYWxob3N0IGtl
cm5lbDogWyAxNjUyLjcxMDQ1MV0gTm9ybWFsIGZyZWU6MTM3MjhrQiBtaW46NTM4MGtCIGxvdzo2
NzI0a0IgaGlnaDo4MDY4a0IgYWN0aXZlX2Fub246MTI0NDU4MGtCIGluYWN0aXZlX2Fub246NDE1
MDkya0IgYWN0aXZlX2ZpbGU6MTE2NDBrQiBpbmFjdGl2ZV9maWxlOjI3NTQ0a0IgdW5ldmljdGFi
bGU6MGtCIGlzb2xhdGVkKGFub24pOjBrQiBpc29sYXRlZChmaWxlKTowa0IgcHJlc2VudDoxODEx
NTIwa0IgbWxvY2tlZDowa0IgZGlydHk6MGtCIHdyaXRlYmFjazowa0IgbWFwcGVkOjIwMTJrQiBz
aG1lbTozMmtCIHNsYWJfcmVjbGFpbWFibGU6ODM4OGtCIHNsYWJfdW5yZWNsYWltYWJsZTo4NjY0
a0Iga2VybmVsX3N0YWNrOjEzMjhrQiBwYWdldGFibGVzOjYxMDhrQiB1bnN0YWJsZTowa0IgYm91
bmNlOjBrQiB3cml0ZWJhY2tfdG1wOjBrQiBwYWdlc19zY2FubmVkOjI2NDE5MTYgYWxsX3VucmVj
bGFpbWFibGU/IG5vCjIwMTItMTEtMjhUMTA6MjE6NTYuOTEzNDc3LTA4OjAwIGxvY2FsaG9zdCBr
ZXJuZWw6IFsgMTY1Mi43MTA0NzVdIGxvd21lbV9yZXNlcnZlW106IDAgMjA5NSAyMDk1CjIwMTIt
MTEtMjhUMTA6MjE6NTYuOTEzNDkxLTA4OjAwIGxvY2FsaG9zdCBrZXJuZWw6IFsgMTY1Mi43MTA1
MDJdIEhpZ2hNZW0gZnJlZToyNjBrQiBtaW46MjYwa0IgbG93OjQ1NmtCIGhpZ2g6NjU2a0IgYWN0
aXZlX2Fub246ODUzODRrQiBpbmFjdGl2ZV9hbm9uOjg1NzAwa0IgYWN0aXZlX2ZpbGU6MjUyMDBr
QiBpbmFjdGl2ZV9maWxlOjI0Njg4a0IgdW5ldmljdGFibGU6MGtCIGlzb2xhdGVkKGFub24pOjhr
QiBpc29sYXRlZChmaWxlKTowa0IgcHJlc2VudDoyNjgyMjRrQiBtbG9ja2VkOjBrQiBkaXJ0eTox
MmtCIHdyaXRlYmFjazowa0IgbWFwcGVkOjExMzg0a0Igc2htZW06MGtCIHNsYWJfcmVjbGFpbWFi
bGU6MGtCIHNsYWJfdW5yZWNsYWltYWJsZTowa0Iga2VybmVsX3N0YWNrOjBrQiBwYWdldGFibGVz
OjBrQiB1bnN0YWJsZTowa0IgYm91bmNlOjBrQiB3cml0ZWJhY2tfdG1wOjBrQiBwYWdlc19zY2Fu
bmVkOjI5MDcwNyBhbGxfdW5yZWNsYWltYWJsZT8geWVzCjIwMTItMTEtMjhUMTA6MjE6NTYuOTEz
NTAwLTA4OjAwIGxvY2FsaG9zdCBrZXJuZWw6IFsgMTY1Mi43MTA1MjZdIGxvd21lbV9yZXNlcnZl
W106IDAgMCAwCjIwMTItMTEtMjhUMTA6MjE6NTYuOTEzNTA4LTA4OjAwIGxvY2FsaG9zdCBrZXJu
ZWw6IFsgMTY1Mi43MTA1NDVdIE5vcm1hbDogNio0a0IgNCo4a0IgMyoxNmtCIDI0KjMya0IgODkq
NjRrQiAwKjEyOGtCIDAqMjU2a0IgMCo1MTJrQiAxKjEwMjRrQiAxKjIwNDhrQiAxKjQwOTZrQiA9
IDEzNzM2a0IKMjAxMi0xMS0yOFQxMDoyMTo1Ni45MTM1MTgtMDg6MDAgbG9jYWxob3N0IGtlcm5l
bDogWyAxNjUyLjcxMDU5N10gSGlnaE1lbTogNjEqNGtCIDQqOGtCIDAqMTZrQiAwKjMya0IgMCo2
NGtCIDAqMTI4a0IgMCoyNTZrQiAwKjUxMmtCIDAqMTAyNGtCIDAqMjA0OGtCIDAqNDA5NmtCID0g
Mjc2a0IKMjAxMi0xMS0yOFQxMDoyMTo1Ni45MTM1MzUtMDg6MDAgbG9jYWxob3N0IGtlcm5lbDog
WyAxNjUyLjcxMDY0OF0gMTEyOTI1IHRvdGFsIHBhZ2VjYWNoZSBwYWdlcwoyMDEyLTExLTI4VDEw
OjIxOjU2LjkxMzU0MS0wODowMCBsb2NhbGhvc3Qga2VybmVsOiBbIDE2NTIuNzEwNjU1XSA5MDY0
NiBwYWdlcyBpbiBzd2FwIGNhY2hlCjIwMTItMTEtMjhUMTA6MjE6NTYuOTEzNTQ4LTA4OjAwIGxv
Y2FsaG9zdCBrZXJuZWw6IFsgMTY1Mi43MTA2NjNdIFN3YXAgY2FjaGUgc3RhdHM6IGFkZCA3MzM1
ODMsIGRlbGV0ZSA2NDI5MzcsIGZpbmQgOTc4NjQvMTYxNDc4CjIwMTItMTEtMjhUMTA6MjE6NTYu
OTEzNTU0LTA4OjAwIGxvY2FsaG9zdCBrZXJuZWw6IFsgMTY1Mi43MTA2NzFdIEZyZWUgc3dhcCAg
PSAyMDA1Mzgwa0IKMjAxMi0xMS0yOFQxMDoyMTo1Ni45MTM1NTktMDg6MDAgbG9jYWxob3N0IGtl
cm5lbDogWyAxNjUyLjcxMDY3N10gVG90YWwgc3dhcCA9IDMwMjg3NjhrQgoyMDEyLTExLTI4VDEw
OjIxOjU2LjkxMzU2NC0wODowMCBsb2NhbGhvc3Qga2VybmVsOiBbIDE2NTIuNzEwNjgzXSBsdWln
aV9ucl9yZWNsYWltZWQgNDk1OTQ4CjIwMTItMTEtMjhUMTA6MjE6NTYuOTEzNTcwLTA4OjAwIGxv
Y2FsaG9zdCBrZXJuZWw6IFsgMTY1Mi43MTA2OTBdIGx1aWdpX25yX3JlY2xhaW1zIDg4MjAKMjAx
Mi0xMS0yOFQxMDoyMTo1Ni45MTM1NzctMDg6MDAgbG9jYWxob3N0IGtlcm5lbDogWyAxNjUyLjcx
MDY5Nl0gbHVpZ2lfYWJvcnRlZF9yZWNsYWltIDAKMjAxMi0xMS0yOFQxMDoyMTo1Ni45MTQ2OTQt
MDg6MDAgbG9jYWxob3N0IGtlcm5lbDogWyAxNjUyLjcxMDcwMl0gbHVpZ2lfbW9yZV90b19kbyAy
MzcKMjAxMi0xMS0yOFQxMDoyMTo1Ni45MTQ3MDQtMDg6MDAgbG9jYWxob3N0IGtlcm5lbDogWyAx
NjUyLjcxMDcwOF0gbHVpZ2lfZGlyZWN0X3JlY2xhaW1zIDkwODYKMjAxMi0xMS0yOFQxMDoyMTo1
Ni45MTQ3MTgtMDg6MDAgbG9jYWxob3N0IGtlcm5lbDogWyAxNjUyLjcxMDcxNF0gbHVpZ2lfZmFp
bGVkX2RpcmVjdF9yZWNsYWltcyA5OAoyMDEyLTExLTI4VDEwOjIxOjU2LjkxNDcyNS0wODowMCBs
b2NhbGhvc3Qga2VybmVsOiBbIDE2NTIuNzEwNzIxXSBsdWlnaV9ub19wcm9ncmVzcyAxCjIwMTIt
MTEtMjhUMTA6MjE6NTYuOTE0NzMwLTA4OjAwIGxvY2FsaG9zdCBrZXJuZWw6IFsgMTY1Mi43MTA3
MjddIGx1aWdpX3Jlc3RhcnRzIDAKMjAxMi0xMS0yOFQxMDoyMTo1Ni45MTQ3MzQtMDg6MDAgbG9j
YWxob3N0IGtlcm5lbDogWyAxNjUyLjcxMDczM10gbHVpZ2lfc2hvdWxkX2FsbG9jX3JldHJ5IDk3
CjIwMTItMTEtMjhUMTA6MjE6NTYuOTE0NzQwLTA4OjAwIGxvY2FsaG9zdCBrZXJuZWw6IFsgMTY1
Mi43MTA3MzldIGx1aWdpX2RpcmVjdF9jb21wYWN0IDAKMjAxMi0xMS0yOFQxMDoyMTo1Ni45MTQ3
NDctMDg6MDAgbG9jYWxob3N0IGtlcm5lbDogWyAxNjUyLjcxMDc0NV0gbHVpZ2lfYWxsb2NfZmFp
bGVkIDExMQoyMDEyLTExLTI4VDEwOjIxOjU2LjkxNDc1Mi0wODowMCBsb2NhbGhvc3Qga2VybmVs
OiBbIDE2NTIuNzEwNzUxXSBsdWlnaV9nZnBfbm9mYWlsIDAKMjAxMi0xMS0yOFQxMDoyMTo1Ni45
MTQ3NTctMDg6MDAgbG9jYWxob3N0IGtlcm5lbDogWyAxNjUyLjcxMDc1N10gbHVpZ2lfY29zdGx5
X29yZGVyIDk3CjIwMTItMTEtMjhUMTA6MjE6NTYuOTE0NzYyLTA4OjAwIGxvY2FsaG9zdCBrZXJu
ZWw6IFsgMTY1Mi43MTA3NjNdIGx1aWdpX3JlcGVhdCAwCjIwMTItMTEtMjhUMTA6MjE6NTYuOTE0
NzY4LTA4OjAwIGxvY2FsaG9zdCBrZXJuZWw6IFsgMTY1Mi43MTA3NjldIGx1aWdpX2tzd2FwZF9u
YXAgNzEKMjAxMi0xMS0yOFQxMDoyMTo1Ni45MTQ3NzktMDg6MDAgbG9jYWxob3N0IGtlcm5lbDog
WyAxNjUyLjcxMDc3NV0gbHVpZ2lfa3N3YXBkX3NsZWVwIDQKMjAxMi0xMS0yOFQxMDoyMTo1Ni45
MTQ3ODUtMDg6MDAgbG9jYWxob3N0IGtlcm5lbDogWyAxNjUyLjcxMDc4MV0gbHVpZ2lfa3N3YXBk
X2xvb3AgNzIKMjAxMi0xMS0yOFQxMDoyMTo1Ni45MTQ3OTEtMDg6MDAgbG9jYWxob3N0IGtlcm5l
bDogWyAxNjUyLjcxMDc4N10gbHVpZ2lfa3N3YXBkX3RyeV90b19zbGVlcCA3MQoyMDEyLTExLTI4
VDEwOjIxOjU2LjkxNDc5Ny0wODowMCBsb2NhbGhvc3Qga2VybmVsOiBbIDE2NTIuNzEwNzkzXSBs
dWlnaV9zbG93cGF0aCA1MzA5NjYKMjAxMi0xMS0yOFQxMDoyMTo1Ni45MTQ4MDMtMDg6MDAgbG9j
YWxob3N0IGtlcm5lbDogWyAxNjUyLjcxMDc5OV0gbHVpZ2lfd2FrZV9hbGxfa3N3YXBkIDUzMDk2
MQoyMDEyLTExLTI4VDEwOjIxOjU2LjkxNDgwOC0wODowMCBsb2NhbGhvc3Qga2VybmVsOiBbIDE2
NTIuNzIxMDg0XSA1MjQyODggcGFnZXMgb2YgUkFNCjIwMTItMTEtMjhUMTA6MjE6NTYuOTE0ODE1
LTA4OjAwIGxvY2FsaG9zdCBrZXJuZWw6IFsgMTY1Mi43MjEwOTRdIDQyNTYgZnJlZSBwYWdlcwoy
MDEyLTExLTI4VDEwOjIxOjU2LjkxNDgyMi0wODowMCBsb2NhbGhvc3Qga2VybmVsOiBbIDE2NTIu
NzIxMTAwXSA3MTIyIHJlc2VydmVkIHBhZ2VzCjIwMTItMTEtMjhUMTA6MjE6NTYuOTE0ODI4LTA4
OjAwIGxvY2FsaG9zdCBrZXJuZWw6IFsgMTY1Mi43MjExMDZdIDI5MjQgc2xhYiBwYWdlcwoyMDEy
LTExLTI4VDEwOjIxOjU2LjkxNDgzNy0wODowMCBsb2NhbGhvc3Qga2VybmVsOiBbIDE2NTIuNzIx
MTEyXSAyMzUxMCBwYWdlcyBzaGFyZWQKMjAxMi0xMS0yOFQxMDoyMTo1Ni45MTQ4NDMtMDg6MDAg
bG9jYWxob3N0IGtlcm5lbDogWyAxNjUyLjcyMTExOF0gOTA2NDYgcGFnZXMgc3dhcCBjYWNoZWQK
--001a113c2ba4f4fdd105531d1b73--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
