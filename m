Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5E5426B000D
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 02:54:27 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id m25-v6so2188224pgv.22
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 23:54:27 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id m13-v6si4230870pgk.251.2018.08.02.23.54.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 23:54:25 -0700 (PDT)
From: "Song, HaiyanX" <haiyanx.song@intel.com>
Subject: RE: [PATCH v11 00/26] Speculative page faults
Date: Fri, 3 Aug 2018 06:45:34 +0000
Message-ID: <9FE19350E8A7EE45B64D8D63D368C8966B876B94@SHSMSX101.ccr.corp.intel.com>
References: <1526555193-7242-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <9FE19350E8A7EE45B64D8D63D368C8966B834B67@SHSMSX101.ccr.corp.intel.com>
 <1327633f-8bb9-99f7-fab4-4cfcbf997200@linux.vnet.ibm.com>
 <20180528082235.e5x4oiaaf7cjoddr@haiyan.lkp.sh.intel.com>
 <316c6936-203d-67e9-c18c-6cf10d0d4bee@linux.vnet.ibm.com>
 <9FE19350E8A7EE45B64D8D63D368C8966B847F54@SHSMSX101.ccr.corp.intel.com>
 <3849e991-1354-d836-94ac-077d29a0dee4@linux.vnet.ibm.com>
 <9FE19350E8A7EE45B64D8D63D368C8966B85F660@SHSMSX101.ccr.corp.intel.com>
 <a69cc75c-8252-246b-5583-04f6a7478ecd@linux.vnet.ibm.com>
 <4f201590-9b5c-1651-282e-7e3b26a069f3@linux.vnet.ibm.com>
 <9FE19350E8A7EE45B64D8D63D368C8966B86A721@SHSMSX101.ccr.corp.intel.com>,<166434ae-ecaf-05d8-3cc7-7aa75bc3737b@linux.vnet.ibm.com>,<9FE19350E8A7EE45B64D8D63D368C8966B876B4B@SHSMSX101.ccr.corp.intel.com>
In-Reply-To: <9FE19350E8A7EE45B64D8D63D368C8966B876B4B@SHSMSX101.ccr.corp.intel.com>
Content-Language: en-US
Content-Type: multipart/mixed;
	boundary="_004_9FE19350E8A7EE45B64D8D63D368C8966B876B94SHSMSX101ccrcor_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "kirill@shutemov.name" <kirill@shutemov.name>, "ak@linux.intel.com" <ak@linux.intel.com>, "dave@stgolabs.net" <dave@stgolabs.net>, "jack@suse.cz" <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "mpe@ellerman.id.au" <mpe@ellerman.id.au>, "paulus@samba.org" <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "sergey.senozhatsky.work@gmail.com" <sergey.senozhatsky.work@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, "Wang, Kemi" <kemi.wang@intel.com>, Daniel
 Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Minchan Kim <minchan@kernel.org>, Punit
 Agrawal <punitagrawal@gmail.com>, vinayak menon <vinayakm.list@gmail.com>, Yang Shi <yang.shi@linux.alibaba.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "haren@linux.vnet.ibm.com" <haren@linux.vnet.ibm.com>, "npiggin@gmail.com" <npiggin@gmail.com>, "bsingharora@gmail.com" <bsingharora@gmail.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "x86@kernel.org" <x86@kernel.org>

--_004_9FE19350E8A7EE45B64D8D63D368C8966B876B94SHSMSX101ccrcor_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Add another 3 perf file.=0A=
________________________________________=0A=
From: Song, HaiyanX=0A=
Sent: Friday, August 03, 2018 2:36 PM=0A=
To: Laurent Dufour=0A=
Cc: akpm@linux-foundation.org; mhocko@kernel.org; peterz@infradead.org; kir=
ill@shutemov.name; ak@linux.intel.com; dave@stgolabs.net; jack@suse.cz; Mat=
thew Wilcox; khandual@linux.vnet.ibm.com; aneesh.kumar@linux.vnet.ibm.com; =
benh@kernel.crashing.org; mpe@ellerman.id.au; paulus@samba.org; Thomas Glei=
xner; Ingo Molnar; hpa@zytor.com; Will Deacon; Sergey Senozhatsky; sergey.s=
enozhatsky.work@gmail.com; Andrea Arcangeli; Alexei Starovoitov; Wang, Kemi=
; Daniel Jordan; David Rientjes; Jerome Glisse; Ganesh Mahendran; Minchan K=
im; Punit Agrawal; vinayak menon; Yang Shi; linux-kernel@vger.kernel.org; l=
inux-mm@kvack.org; haren@linux.vnet.ibm.com; npiggin@gmail.com; bsingharora=
@gmail.com; paulmck@linux.vnet.ibm.com; Tim Chen; linuxppc-dev@lists.ozlabs=
.org; x86@kernel.org=0A=
Subject: RE: [PATCH v11 00/26] Speculative page faults=0A=
=0A=
Hi Laurent,=0A=
=0A=
Thanks for your analysis for the last perf results.=0A=
Your mentioned ," the major differences at the head of the perf report is t=
he 92% testcase which is weirdly not reported=0A=
on the head side", which is a bug of 0-day,and it caused the item is not co=
unted in perf.=0A=
=0A=
I've triggered the test page_fault2 and page_fault3 again only with thread =
mode of will-it-scale on 0-day (on the same test box,every case tested 3 ti=
mes).=0A=
I checked the perf report have no above mentioned problem.=0A=
=0A=
I have compared them, found some items have difference, such as below case:=
=0A=
       page_fault2-thp-always: handle_mm_fault, base: 45.22%    head: 29.41=
%=0A=
       page_fault3-thp-always: handle_mm_fault, base: 22.95%    head: 14.15=
%=0A=
=0A=
So i attached the perf result in mail again, could your have a look again f=
or checking the difference between base and head commit.=0A=
=0A=
=0A=
Thanks,=0A=
Haiyan, Song=0A=
=0A=
________________________________________=0A=
From: owner-linux-mm@kvack.org [owner-linux-mm@kvack.org] on behalf of Laur=
ent Dufour [ldufour@linux.vnet.ibm.com]=0A=
Sent: Tuesday, July 17, 2018 5:36 PM=0A=
To: Song, HaiyanX=0A=
Cc: akpm@linux-foundation.org; mhocko@kernel.org; peterz@infradead.org; kir=
ill@shutemov.name; ak@linux.intel.com; dave@stgolabs.net; jack@suse.cz; Mat=
thew Wilcox; khandual@linux.vnet.ibm.com; aneesh.kumar@linux.vnet.ibm.com; =
benh@kernel.crashing.org; mpe@ellerman.id.au; paulus@samba.org; Thomas Glei=
xner; Ingo Molnar; hpa@zytor.com; Will Deacon; Sergey Senozhatsky; sergey.s=
enozhatsky.work@gmail.com; Andrea Arcangeli; Alexei Starovoitov; Wang, Kemi=
; Daniel Jordan; David Rientjes; Jerome Glisse; Ganesh Mahendran; Minchan K=
im; Punit Agrawal; vinayak menon; Yang Shi; linux-kernel@vger.kernel.org; l=
inux-mm@kvack.org; haren@linux.vnet.ibm.com; npiggin@gmail.com; bsingharora=
@gmail.com; paulmck@linux.vnet.ibm.com; Tim Chen; linuxppc-dev@lists.ozlabs=
.org; x86@kernel.org=0A=
Subject: Re: [PATCH v11 00/26] Speculative page faults=0A=
=0A=
On 13/07/2018 05:56, Song, HaiyanX wrote:=0A=
> Hi Laurent,=0A=
=0A=
Hi Haiyan,=0A=
=0A=
Thanks a lot for sharing this perf reports.=0A=
=0A=
I looked at them closely, and I've to admit that I was not able to found a=
=0A=
major difference between the base and the head report, except that=0A=
handle_pte_fault() is no more in-lined in the head one.=0A=
=0A=
As expected, __handle_speculative_fault() is never traced since these tests=
 are=0A=
dealing with file mapping, not handled in the speculative way.=0A=
=0A=
When running these test did you seen a major differences in the test's resu=
lt=0A=
between base and head ?=0A=
=0A=
>From the number of cycles counted, the biggest difference is page_fault3 wh=
en=0A=
run with the THP enabled:=0A=
                                BASE            HEAD            Delta=0A=
page_fault2_base_thp_never      1142252426747   1065866197589   -6.69%=0A=
page_fault2_base_THP-Alwasys    1124844374523   1076312228927   -4.31%=0A=
page_fault3_base_thp_never      1099387298152   1134118402345   3.16%=0A=
page_fault3_base_THP-Always     1059370178101   853985561949    -19.39%=0A=
=0A=
=0A=
The very weird thing is the difference of the delta cycles reported between=
=0A=
thp never and thp always, because the speculative way is aborted when check=
ing=0A=
for the vma->ops field, which is the same in both case, and the thp is neve=
r=0A=
checked. So there is no code covering differnce, on the speculative path,=
=0A=
between these 2 cases. This leads me to think that there are other interact=
ions=0A=
interfering in the measure.=0A=
=0A=
Looking at the perf-profile_page_fault3_*_THP-Always, the major differences=
 at=0A=
the head of the perf report is the 92% testcase which is weirdly not report=
ed=0A=
on the head side :=0A=
    92.02%    22.33%  page_fault3_processes  [.] testcase=0A=
92.02% testcase=0A=
=0A=
Then the base reported 37.67% for __do_page_fault() where the head reported=
=0A=
48.41%, but the only difference in this function, between base and head, is=
 the=0A=
call to handle_speculative_fault(). But this is a macro checking for the fa=
ult=0A=
flags, and mm->users and then calling __handle_speculative_fault() if neede=
d.=0A=
So this can't explain this difference, except if __handle_speculative_fault=
()=0A=
is inlined in __do_page_fault().=0A=
Is this the case on your build ?=0A=
=0A=
Haiyan, do you still have the output of the test to check those numbers too=
 ?=0A=
=0A=
Cheers,=0A=
Laurent=0A=
=0A=
> I attached the perf-profile.gz file for case page_fault2 and page_fault3.=
 These files were captured during test the related test case.=0A=
> Please help to check on these data if it can help you to find the higher =
change. Thanks.=0A=
>=0A=
> File name perf-profile_page_fault2_head_THP-Always.gz, means the perf-pro=
file result get from page_fault2=0A=
>     tested for head commit (a7a8993bfe3ccb54ad468b9f1799649e4ad1ff12) wit=
h THP_always configuration.=0A=
>=0A=
> Best regards,=0A=
> Haiyan Song=0A=
>=0A=
> ________________________________________=0A=
> From: owner-linux-mm@kvack.org [owner-linux-mm@kvack.org] on behalf of La=
urent Dufour [ldufour@linux.vnet.ibm.com]=0A=
> Sent: Thursday, July 12, 2018 1:05 AM=0A=
> To: Song, HaiyanX=0A=
> Cc: akpm@linux-foundation.org; mhocko@kernel.org; peterz@infradead.org; k=
irill@shutemov.name; ak@linux.intel.com; dave@stgolabs.net; jack@suse.cz; M=
atthew Wilcox; khandual@linux.vnet.ibm.com; aneesh.kumar@linux.vnet.ibm.com=
; benh@kernel.crashing.org; mpe@ellerman.id.au; paulus@samba.org; Thomas Gl=
eixner; Ingo Molnar; hpa@zytor.com; Will Deacon; Sergey Senozhatsky; sergey=
.senozhatsky.work@gmail.com; Andrea Arcangeli; Alexei Starovoitov; Wang, Ke=
mi; Daniel Jordan; David Rientjes; Jerome Glisse; Ganesh Mahendran; Minchan=
 Kim; Punit Agrawal; vinayak menon; Yang Shi; linux-kernel@vger.kernel.org;=
 linux-mm@kvack.org; haren@linux.vnet.ibm.com; npiggin@gmail.com; bsingharo=
ra@gmail.com; paulmck@linux.vnet.ibm.com; Tim Chen; linuxppc-dev@lists.ozla=
bs.org; x86@kernel.org=0A=
> Subject: Re: [PATCH v11 00/26] Speculative page faults=0A=
>=0A=
> Hi Haiyan,=0A=
>=0A=
> Do you get a chance to capture some performance cycles on your system ?=
=0A=
> I still can't get these numbers on my hardware.=0A=
>=0A=
> Thanks,=0A=
> Laurent.=0A=
>=0A=
> On 04/07/2018 09:51, Laurent Dufour wrote:=0A=
>> On 04/07/2018 05:23, Song, HaiyanX wrote:=0A=
>>> Hi Laurent,=0A=
>>>=0A=
>>>=0A=
>>> For the test result on Intel 4s skylake platform (192 CPUs, 768G Memory=
), the below test cases all were run 3 times.=0A=
>>> I check the test results, only page_fault3_thread/enable THP have 6% st=
ddev for head commit, other tests have lower stddev.=0A=
>>=0A=
>> Repeating the test only 3 times seems a bit too low to me.=0A=
>>=0A=
>> I'll focus on the higher change for the moment, but I don't have access =
to such=0A=
>> a hardware.=0A=
>>=0A=
>> Is possible to provide a diff between base and SPF of the performance cy=
cles=0A=
>> measured when running page_fault3 and page_fault2 when the 20% change is=
 detected.=0A=
>>=0A=
>> Please stay focus on the test case process to see exactly where the seri=
es is=0A=
>> impacting.=0A=
>>=0A=
>> Thanks,=0A=
>> Laurent.=0A=
>>=0A=
>>>=0A=
>>> And I did not find other high variation on test case result.=0A=
>>>=0A=
>>> a). Enable THP=0A=
>>> testcase                          base     stddev       change      hea=
d     stddev         metric=0A=
>>> page_fault3/enable THP           10519      =B1 3%        -20.5%      8=
368      =B16%          will-it-scale.per_thread_ops=0A=
>>> page_fault2/enalbe THP            8281      =B1 2%        -18.8%      6=
728                   will-it-scale.per_thread_ops=0A=
>>> brk1/eanble THP                 998475                   -2.2%    97689=
3                   will-it-scale.per_process_ops=0A=
>>> context_switch1/enable THP      223910                   -1.3%    22093=
0                   will-it-scale.per_process_ops=0A=
>>> context_switch1/enable THP      233722                   -1.0%    23128=
8                   will-it-scale.per_thread_ops=0A=
>>>=0A=
>>> b). Disable THP=0A=
>>> page_fault3/disable THP          10856                  -23.1%      834=
4                   will-it-scale.per_thread_ops=0A=
>>> page_fault2/disable THP           8147                  -18.8%      661=
3                   will-it-scale.per_thread_ops=0A=
>>> brk1/disable THP                   957                    -7.9%      88=
1                   will-it-scale.per_thread_ops=0A=
>>> context_switch1/disable THP     237006                    -2.2%    2319=
07                  will-it-scale.per_thread_ops=0A=
>>> brk1/disable THP                997317                    -2.0%    9777=
78                  will-it-scale.per_process_ops=0A=
>>> page_fault3/disable THP         467454                    -1.8%    4592=
51                  will-it-scale.per_process_ops=0A=
>>> context_switch1/disable THP     224431                    -1.3%    2215=
67                  will-it-scale.per_process_ops=0A=
>>>=0A=
>>>=0A=
>>> Best regards,=0A=
>>> Haiyan Song=0A=
>>> ________________________________________=0A=
>>> From: Laurent Dufour [ldufour@linux.vnet.ibm.com]=0A=
>>> Sent: Monday, July 02, 2018 4:59 PM=0A=
>>> To: Song, HaiyanX=0A=
>>> Cc: akpm@linux-foundation.org; mhocko@kernel.org; peterz@infradead.org;=
 kirill@shutemov.name; ak@linux.intel.com; dave@stgolabs.net; jack@suse.cz;=
 Matthew Wilcox; khandual@linux.vnet.ibm.com; aneesh.kumar@linux.vnet.ibm.c=
om; benh@kernel.crashing.org; mpe@ellerman.id.au; paulus@samba.org; Thomas =
Gleixner; Ingo Molnar; hpa@zytor.com; Will Deacon; Sergey Senozhatsky; serg=
ey.senozhatsky.work@gmail.com; Andrea Arcangeli; Alexei Starovoitov; Wang, =
Kemi; Daniel Jordan; David Rientjes; Jerome Glisse; Ganesh Mahendran; Minch=
an Kim; Punit Agrawal; vinayak menon; Yang Shi; linux-kernel@vger.kernel.or=
g; linux-mm@kvack.org; haren@linux.vnet.ibm.com; npiggin@gmail.com; bsingha=
rora@gmail.com; paulmck@linux.vnet.ibm.com; Tim Chen; linuxppc-dev@lists.oz=
labs.org; x86@kernel.org=0A=
>>> Subject: Re: [PATCH v11 00/26] Speculative page faults=0A=
>>>=0A=
>>> On 11/06/2018 09:49, Song, HaiyanX wrote:=0A=
>>>> Hi Laurent,=0A=
>>>>=0A=
>>>> Regression test for v11 patch serials have been run, some regression i=
s found by LKP-tools (linux kernel performance)=0A=
>>>> tested on Intel 4s skylake platform. This time only test the cases whi=
ch have been run and found regressions on=0A=
>>>> V9 patch serials.=0A=
>>>>=0A=
>>>> The regression result is sorted by the metric will-it-scale.per_thread=
_ops.=0A=
>>>> branch: Laurent-Dufour/Speculative-page-faults/20180520-045126=0A=
>>>> commit id:=0A=
>>>>   head commit : a7a8993bfe3ccb54ad468b9f1799649e4ad1ff12=0A=
>>>>   base commit : ba98a1cdad71d259a194461b3a61471b49b14df1=0A=
>>>> Benchmark: will-it-scale=0A=
>>>> Download link: https://github.com/antonblanchard/will-it-scale/tree/ma=
ster=0A=
>>>>=0A=
>>>> Metrics:=0A=
>>>>   will-it-scale.per_process_ops=3Dprocesses/nr_cpu=0A=
>>>>   will-it-scale.per_thread_ops=3Dthreads/nr_cpu=0A=
>>>>   test box: lkp-skl-4sp1(nr_cpu=3D192,memory=3D768G)=0A=
>>>> THP: enable / disable=0A=
>>>> nr_task:100%=0A=
>>>>=0A=
>>>> 1. Regressions:=0A=
>>>>=0A=
>>>> a). Enable THP=0A=
>>>> testcase                          base           change      head     =
      metric=0A=
>>>> page_fault3/enable THP           10519          -20.5%        836     =
 will-it-scale.per_thread_ops=0A=
>>>> page_fault2/enalbe THP            8281          -18.8%       6728     =
 will-it-scale.per_thread_ops=0A=
>>>> brk1/eanble THP                 998475           -2.2%     976893     =
 will-it-scale.per_process_ops=0A=
>>>> context_switch1/enable THP      223910           -1.3%     220930     =
 will-it-scale.per_process_ops=0A=
>>>> context_switch1/enable THP      233722           -1.0%     231288     =
 will-it-scale.per_thread_ops=0A=
>>>>=0A=
>>>> b). Disable THP=0A=
>>>> page_fault3/disable THP          10856          -23.1%       8344     =
 will-it-scale.per_thread_ops=0A=
>>>> page_fault2/disable THP           8147          -18.8%       6613     =
 will-it-scale.per_thread_ops=0A=
>>>> brk1/disable THP                   957           -7.9%        881     =
 will-it-scale.per_thread_ops=0A=
>>>> context_switch1/disable THP     237006           -2.2%     231907     =
 will-it-scale.per_thread_ops=0A=
>>>> brk1/disable THP                997317           -2.0%     977778     =
 will-it-scale.per_process_ops=0A=
>>>> page_fault3/disable THP         467454           -1.8%     459251     =
 will-it-scale.per_process_ops=0A=
>>>> context_switch1/disable THP     224431           -1.3%     221567     =
 will-it-scale.per_process_ops=0A=
>>>>=0A=
>>>> Notes: for the above  values of test result, the higher is better.=0A=
>>>=0A=
>>> I tried the same tests on my PowerPC victim VM (1024 CPUs, 11TB) and I =
can't=0A=
>>> get reproducible results. The results have huge variation, even on the =
vanilla=0A=
>>> kernel, and I can't state on any changes due to that.=0A=
>>>=0A=
>>> I tried on smaller node (80 CPUs, 32G), and the tests ran better, but I=
 didn't=0A=
>>> measure any changes between the vanilla and the SPF patched ones:=0A=
>>>=0A=
>>> test THP enabled                4.17.0-rc4-mm1  spf             delta=
=0A=
>>> page_fault3_threads             2697.7          2683.5          -0.53%=
=0A=
>>> page_fault2_threads             170660.6        169574.1        -0.64%=
=0A=
>>> context_switch1_threads         6915269.2       6877507.3       -0.55%=
=0A=
>>> context_switch1_processes       6478076.2       6529493.5       0.79%=
=0A=
>>> brk1                            243391.2        238527.5        -2.00%=
=0A=
>>>=0A=
>>> Tests were run 10 times, no high variation detected.=0A=
>>>=0A=
>>> Did you see high variation on your side ? How many times the test were =
run to=0A=
>>> compute the average values ?=0A=
>>>=0A=
>>> Thanks,=0A=
>>> Laurent.=0A=
>>>=0A=
>>>=0A=
>>>>=0A=
>>>> 2. Improvement: not found improvement based on the selected test cases=
.=0A=
>>>>=0A=
>>>>=0A=
>>>> Best regards=0A=
>>>> Haiyan Song=0A=
>>>> ________________________________________=0A=
>>>> From: owner-linux-mm@kvack.org [owner-linux-mm@kvack.org] on behalf of=
 Laurent Dufour [ldufour@linux.vnet.ibm.com]=0A=
>>>> Sent: Monday, May 28, 2018 4:54 PM=0A=
>>>> To: Song, HaiyanX=0A=
>>>> Cc: akpm@linux-foundation.org; mhocko@kernel.org; peterz@infradead.org=
; kirill@shutemov.name; ak@linux.intel.com; dave@stgolabs.net; jack@suse.cz=
; Matthew Wilcox; khandual@linux.vnet.ibm.com; aneesh.kumar@linux.vnet.ibm.=
com; benh@kernel.crashing.org; mpe@ellerman.id.au; paulus@samba.org; Thomas=
 Gleixner; Ingo Molnar; hpa@zytor.com; Will Deacon; Sergey Senozhatsky; ser=
gey.senozhatsky.work@gmail.com; Andrea Arcangeli; Alexei Starovoitov; Wang,=
 Kemi; Daniel Jordan; David Rientjes; Jerome Glisse; Ganesh Mahendran; Minc=
han Kim; Punit Agrawal; vinayak menon; Yang Shi; linux-kernel@vger.kernel.o=
rg; linux-mm@kvack.org; haren@linux.vnet.ibm.com; npiggin@gmail.com; bsingh=
arora@gmail.com; paulmck@linux.vnet.ibm.com; Tim Chen; linuxppc-dev@lists.o=
zlabs.org; x86@kernel.org=0A=
>>>> Subject: Re: [PATCH v11 00/26] Speculative page faults=0A=
>>>>=0A=
>>>> On 28/05/2018 10:22, Haiyan Song wrote:=0A=
>>>>> Hi Laurent,=0A=
>>>>>=0A=
>>>>> Yes, these tests are done on V9 patch.=0A=
>>>>=0A=
>>>> Do you plan to give this V11 a run ?=0A=
>>>>=0A=
>>>>>=0A=
>>>>>=0A=
>>>>> Best regards,=0A=
>>>>> Haiyan Song=0A=
>>>>>=0A=
>>>>> On Mon, May 28, 2018 at 09:51:34AM +0200, Laurent Dufour wrote:=0A=
>>>>>> On 28/05/2018 07:23, Song, HaiyanX wrote:=0A=
>>>>>>>=0A=
>>>>>>> Some regression and improvements is found by LKP-tools(linux kernel=
 performance) on V9 patch series=0A=
>>>>>>> tested on Intel 4s Skylake platform.=0A=
>>>>>>=0A=
>>>>>> Hi,=0A=
>>>>>>=0A=
>>>>>> Thanks for reporting this benchmark results, but you mentioned the "=
V9 patch=0A=
>>>>>> series" while responding to the v11 header series...=0A=
>>>>>> Were these tests done on v9 or v11 ?=0A=
>>>>>>=0A=
>>>>>> Cheers,=0A=
>>>>>> Laurent.=0A=
>>>>>>=0A=
>>>>>>>=0A=
>>>>>>> The regression result is sorted by the metric will-it-scale.per_thr=
ead_ops.=0A=
>>>>>>> Branch: Laurent-Dufour/Speculative-page-faults/20180316-151833 (V9 =
patch series)=0A=
>>>>>>> Commit id:=0A=
>>>>>>>     base commit: d55f34411b1b126429a823d06c3124c16283231f=0A=
>>>>>>>     head commit: 0355322b3577eeab7669066df42c550a56801110=0A=
>>>>>>> Benchmark suite: will-it-scale=0A=
>>>>>>> Download link:=0A=
>>>>>>> https://github.com/antonblanchard/will-it-scale/tree/master/tests=
=0A=
>>>>>>> Metrics:=0A=
>>>>>>>     will-it-scale.per_process_ops=3Dprocesses/nr_cpu=0A=
>>>>>>>     will-it-scale.per_thread_ops=3Dthreads/nr_cpu=0A=
>>>>>>> test box: lkp-skl-4sp1(nr_cpu=3D192,memory=3D768G)=0A=
>>>>>>> THP: enable / disable=0A=
>>>>>>> nr_task: 100%=0A=
>>>>>>>=0A=
>>>>>>> 1. Regressions:=0A=
>>>>>>> a) THP enabled:=0A=
>>>>>>> testcase                        base            change          hea=
d       metric=0A=
>>>>>>> page_fault3/ enable THP         10092           -17.5%          832=
3       will-it-scale.per_thread_ops=0A=
>>>>>>> page_fault2/ enable THP          8300           -17.2%          686=
9       will-it-scale.per_thread_ops=0A=
>>>>>>> brk1/ enable THP                  957.67         -7.6%           88=
5       will-it-scale.per_thread_ops=0A=
>>>>>>> page_fault3/ enable THP        172821            -5.3%        16369=
2       will-it-scale.per_process_ops=0A=
>>>>>>> signal1/ enable THP              9125            -3.2%          883=
4       will-it-scale.per_process_ops=0A=
>>>>>>>=0A=
>>>>>>> b) THP disabled:=0A=
>>>>>>> testcase                        base            change          hea=
d       metric=0A=
>>>>>>> page_fault3/ disable THP        10107           -19.1%          818=
0       will-it-scale.per_thread_ops=0A=
>>>>>>> page_fault2/ disable THP         8432           -17.8%          693=
1       will-it-scale.per_thread_ops=0A=
>>>>>>> context_switch1/ disable THP   215389            -6.8%        20077=
6       will-it-scale.per_thread_ops=0A=
>>>>>>> brk1/ disable THP                 939.67         -6.6%           87=
7.33    will-it-scale.per_thread_ops=0A=
>>>>>>> page_fault3/ disable THP       173145            -4.7%        16506=
4       will-it-scale.per_process_ops=0A=
>>>>>>> signal1/ disable THP             9162            -3.9%          880=
2       will-it-scale.per_process_ops=0A=
>>>>>>>=0A=
>>>>>>> 2. Improvements:=0A=
>>>>>>> a) THP enabled:=0A=
>>>>>>> testcase                        base            change          hea=
d       metric=0A=
>>>>>>> malloc1/ enable THP               66.33        +469.8%           38=
3.67    will-it-scale.per_thread_ops=0A=
>>>>>>> writeseek3/ enable THP          2531             +4.5%          264=
6       will-it-scale.per_thread_ops=0A=
>>>>>>> signal1/ enable THP              989.33          +2.8%          101=
6       will-it-scale.per_thread_ops=0A=
>>>>>>>=0A=
>>>>>>> b) THP disabled:=0A=
>>>>>>> testcase                        base            change          hea=
d       metric=0A=
>>>>>>> malloc1/ disable THP              90.33        +417.3%           46=
7.33    will-it-scale.per_thread_ops=0A=
>>>>>>> read2/ disable THP             58934            +39.2%         8206=
0       will-it-scale.per_thread_ops=0A=
>>>>>>> page_fault1/ disable THP        8607            +36.4%         1173=
6       will-it-scale.per_thread_ops=0A=
>>>>>>> read1/ disable THP            314063            +12.7%        35393=
4       will-it-scale.per_thread_ops=0A=
>>>>>>> writeseek3/ disable THP         2452            +12.5%          275=
9       will-it-scale.per_thread_ops=0A=
>>>>>>> signal1/ disable THP             971.33          +5.5%          102=
4       will-it-scale.per_thread_ops=0A=
>>>>>>>=0A=
>>>>>>> Notes: for above values in column "change", the higher value means =
that the related testcase result=0A=
>>>>>>> on head commit is better than that on base commit for this benchmar=
k.=0A=
>>>>>>>=0A=
>>>>>>>=0A=
>>>>>>> Best regards=0A=
>>>>>>> Haiyan Song=0A=
>>>>>>>=0A=
>>>>>>> ________________________________________=0A=
>>>>>>> From: owner-linux-mm@kvack.org [owner-linux-mm@kvack.org] on behalf=
 of Laurent Dufour [ldufour@linux.vnet.ibm.com]=0A=
>>>>>>> Sent: Thursday, May 17, 2018 7:06 PM=0A=
>>>>>>> To: akpm@linux-foundation.org; mhocko@kernel.org; peterz@infradead.=
org; kirill@shutemov.name; ak@linux.intel.com; dave@stgolabs.net; jack@suse=
.cz; Matthew Wilcox; khandual@linux.vnet.ibm.com; aneesh.kumar@linux.vnet.i=
bm.com; benh@kernel.crashing.org; mpe@ellerman.id.au; paulus@samba.org; Tho=
mas Gleixner; Ingo Molnar; hpa@zytor.com; Will Deacon; Sergey Senozhatsky; =
sergey.senozhatsky.work@gmail.com; Andrea Arcangeli; Alexei Starovoitov; Wa=
ng, Kemi; Daniel Jordan; David Rientjes; Jerome Glisse; Ganesh Mahendran; M=
inchan Kim; Punit Agrawal; vinayak menon; Yang Shi=0A=
>>>>>>> Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org; haren@linux.v=
net.ibm.com; npiggin@gmail.com; bsingharora@gmail.com; paulmck@linux.vnet.i=
bm.com; Tim Chen; linuxppc-dev@lists.ozlabs.org; x86@kernel.org=0A=
>>>>>>> Subject: [PATCH v11 00/26] Speculative page faults=0A=
>>>>>>>=0A=
>>>>>>> This is a port on kernel 4.17 of the work done by Peter Zijlstra to=
 handle=0A=
>>>>>>> page fault without holding the mm semaphore [1].=0A=
>>>>>>>=0A=
>>>>>>> The idea is to try to handle user space page faults without holding=
 the=0A=
>>>>>>> mmap_sem. This should allow better concurrency for massively thread=
ed=0A=
>>>>>>> process since the page fault handler will not wait for other thread=
s memory=0A=
>>>>>>> layout change to be done, assuming that this change is done in anot=
her part=0A=
>>>>>>> of the process's memory space. This type page fault is named specul=
ative=0A=
>>>>>>> page fault. If the speculative page fault fails because of a concur=
rency is=0A=
>>>>>>> detected or because underlying PMD or PTE tables are not yet alloca=
ting, it=0A=
>>>>>>> is failing its processing and a classic page fault is then tried.=
=0A=
>>>>>>>=0A=
>>>>>>> The speculative page fault (SPF) has to look for the VMA matching t=
he fault=0A=
>>>>>>> address without holding the mmap_sem, this is done by introducing a=
 rwlock=0A=
>>>>>>> which protects the access to the mm_rb tree. Previously this was do=
ne using=0A=
>>>>>>> SRCU but it was introducing a lot of scheduling to process the VMA'=
s=0A=
>>>>>>> freeing operation which was hitting the performance by 20% as repor=
ted by=0A=
>>>>>>> Kemi Wang [2]. Using a rwlock to protect access to the mm_rb tree i=
s=0A=
>>>>>>> limiting the locking contention to these operations which are expec=
ted to=0A=
>>>>>>> be in a O(log n) order. In addition to ensure that the VMA is not f=
reed in=0A=
>>>>>>> our back a reference count is added and 2 services (get_vma() and=
=0A=
>>>>>>> put_vma()) are introduced to handle the reference count. Once a VMA=
 is=0A=
>>>>>>> fetched from the RB tree using get_vma(), it must be later freed us=
ing=0A=
>>>>>>> put_vma(). I can't see anymore the overhead I got while will-it-sca=
le=0A=
>>>>>>> benchmark anymore.=0A=
>>>>>>>=0A=
>>>>>>> The VMA's attributes checked during the speculative page fault proc=
essing=0A=
>>>>>>> have to be protected against parallel changes. This is done by usin=
g a per=0A=
>>>>>>> VMA sequence lock. This sequence lock allows the speculative page f=
ault=0A=
>>>>>>> handler to fast check for parallel changes in progress and to abort=
 the=0A=
>>>>>>> speculative page fault in that case.=0A=
>>>>>>>=0A=
>>>>>>> Once the VMA has been found, the speculative page fault handler wou=
ld check=0A=
>>>>>>> for the VMA's attributes to verify that the page fault has to be ha=
ndled=0A=
>>>>>>> correctly or not. Thus, the VMA is protected through a sequence loc=
k which=0A=
>>>>>>> allows fast detection of concurrent VMA changes. If such a change i=
s=0A=
>>>>>>> detected, the speculative page fault is aborted and a *classic* pag=
e fault=0A=
>>>>>>> is tried.  VMA sequence lockings are added when VMA attributes whic=
h are=0A=
>>>>>>> checked during the page fault are modified.=0A=
>>>>>>>=0A=
>>>>>>> When the PTE is fetched, the VMA is checked to see if it has been c=
hanged,=0A=
>>>>>>> so once the page table is locked, the VMA is valid, so any other ch=
anges=0A=
>>>>>>> leading to touching this PTE will need to lock the page table, so n=
o=0A=
>>>>>>> parallel change is possible at this time.=0A=
>>>>>>>=0A=
>>>>>>> The locking of the PTE is done with interrupts disabled, this allow=
s=0A=
>>>>>>> checking for the PMD to ensure that there is not an ongoing collaps=
ing=0A=
>>>>>>> operation. Since khugepaged is firstly set the PMD to pmd_none and =
then is=0A=
>>>>>>> waiting for the other CPU to have caught the IPI interrupt, if the =
pmd is=0A=
>>>>>>> valid at the time the PTE is locked, we have the guarantee that the=
=0A=
>>>>>>> collapsing operation will have to wait on the PTE lock to move forw=
ard.=0A=
>>>>>>> This allows the SPF handler to map the PTE safely. If the PMD value=
 is=0A=
>>>>>>> different from the one recorded at the beginning of the SPF operati=
on, the=0A=
>>>>>>> classic page fault handler will be called to handle the operation w=
hile=0A=
>>>>>>> holding the mmap_sem. As the PTE lock is done with the interrupts d=
isabled,=0A=
>>>>>>> the lock is done using spin_trylock() to avoid dead lock when handl=
ing a=0A=
>>>>>>> page fault while a TLB invalidate is requested by another CPU holdi=
ng the=0A=
>>>>>>> PTE.=0A=
>>>>>>>=0A=
>>>>>>> In pseudo code, this could be seen as:=0A=
>>>>>>>     speculative_page_fault()=0A=
>>>>>>>     {=0A=
>>>>>>>             vma =3D get_vma()=0A=
>>>>>>>             check vma sequence count=0A=
>>>>>>>             check vma's support=0A=
>>>>>>>             disable interrupt=0A=
>>>>>>>                   check pgd,p4d,...,pte=0A=
>>>>>>>                   save pmd and pte in vmf=0A=
>>>>>>>                   save vma sequence counter in vmf=0A=
>>>>>>>             enable interrupt=0A=
>>>>>>>             check vma sequence count=0A=
>>>>>>>             handle_pte_fault(vma)=0A=
>>>>>>>                     ..=0A=
>>>>>>>                     page =3D alloc_page()=0A=
>>>>>>>                     pte_map_lock()=0A=
>>>>>>>                             disable interrupt=0A=
>>>>>>>                                     abort if sequence counter has c=
hanged=0A=
>>>>>>>                                     abort if pmd or pte has changed=
=0A=
>>>>>>>                                     pte map and lock=0A=
>>>>>>>                             enable interrupt=0A=
>>>>>>>                     if abort=0A=
>>>>>>>                        free page=0A=
>>>>>>>                        abort=0A=
>>>>>>>                     ...=0A=
>>>>>>>     }=0A=
>>>>>>>=0A=
>>>>>>>     arch_fault_handler()=0A=
>>>>>>>     {=0A=
>>>>>>>             if (speculative_page_fault(&vma))=0A=
>>>>>>>                goto done=0A=
>>>>>>>     again:=0A=
>>>>>>>             lock(mmap_sem)=0A=
>>>>>>>             vma =3D find_vma();=0A=
>>>>>>>             handle_pte_fault(vma);=0A=
>>>>>>>             if retry=0A=
>>>>>>>                unlock(mmap_sem)=0A=
>>>>>>>                goto again;=0A=
>>>>>>>     done:=0A=
>>>>>>>             handle fault error=0A=
>>>>>>>     }=0A=
>>>>>>>=0A=
>>>>>>> Support for THP is not done because when checking for the PMD, we c=
an be=0A=
>>>>>>> confused by an in progress collapsing operation done by khugepaged.=
 The=0A=
>>>>>>> issue is that pmd_none() could be true either if the PMD is not alr=
eady=0A=
>>>>>>> populated or if the underlying PTE are in the way to be collapsed. =
So we=0A=
>>>>>>> cannot safely allocate a PMD if pmd_none() is true.=0A=
>>>>>>>=0A=
>>>>>>> This series add a new software performance event named 'speculative=
-faults'=0A=
>>>>>>> or 'spf'. It counts the number of successful page fault event handl=
ed=0A=
>>>>>>> speculatively. When recording 'faults,spf' events, the faults one i=
s=0A=
>>>>>>> counting the total number of page fault events while 'spf' is only =
counting=0A=
>>>>>>> the part of the faults processed speculatively.=0A=
>>>>>>>=0A=
>>>>>>> There are some trace events introduced by this series. They allow=
=0A=
>>>>>>> identifying why the page faults were not processed speculatively. T=
his=0A=
>>>>>>> doesn't take in account the faults generated by a monothreaded proc=
ess=0A=
>>>>>>> which directly processed while holding the mmap_sem. This trace eve=
nts are=0A=
>>>>>>> grouped in a system named 'pagefault', they are:=0A=
>>>>>>>  - pagefault:spf_vma_changed : if the VMA has been changed in our b=
ack=0A=
>>>>>>>  - pagefault:spf_vma_noanon : the vma->anon_vma field was not yet s=
et.=0A=
>>>>>>>  - pagefault:spf_vma_notsup : the VMA's type is not supported=0A=
>>>>>>>  - pagefault:spf_vma_access : the VMA's access right are not respec=
ted=0A=
>>>>>>>  - pagefault:spf_pmd_changed : the upper PMD pointer has changed in=
 our=0A=
>>>>>>>    back.=0A=
>>>>>>>=0A=
>>>>>>> To record all the related events, the easier is to run perf with th=
e=0A=
>>>>>>> following arguments :=0A=
>>>>>>> $ perf stat -e 'faults,spf,pagefault:*' <command>=0A=
>>>>>>>=0A=
>>>>>>> There is also a dedicated vmstat counter showing the number of succ=
essful=0A=
>>>>>>> page fault handled speculatively. I can be seen this way:=0A=
>>>>>>> $ grep speculative_pgfault /proc/vmstat=0A=
>>>>>>>=0A=
>>>>>>> This series builds on top of v4.16-mmotm-2018-04-13-17-28 and is fu=
nctional=0A=
>>>>>>> on x86, PowerPC and arm64.=0A=
>>>>>>>=0A=
>>>>>>> ---------------------=0A=
>>>>>>> Real Workload results=0A=
>>>>>>>=0A=
>>>>>>> As mentioned in previous email, we did non official runs using a "p=
opular=0A=
>>>>>>> in memory multithreaded database product" on 176 cores SMT8 Power s=
ystem=0A=
>>>>>>> which showed a 30% improvements in the number of transaction proces=
sed per=0A=
>>>>>>> second. This run has been done on the v6 series, but changes introd=
uced in=0A=
>>>>>>> this new version should not impact the performance boost seen.=0A=
>>>>>>>=0A=
>>>>>>> Here are the perf data captured during 2 of these runs on top of th=
e v8=0A=
>>>>>>> series:=0A=
>>>>>>>                 vanilla         spf=0A=
>>>>>>> faults          89.418          101.364         +13%=0A=
>>>>>>> spf                n/a           97.989=0A=
>>>>>>>=0A=
>>>>>>> With the SPF kernel, most of the page fault were processed in a spe=
culative=0A=
>>>>>>> way.=0A=
>>>>>>>=0A=
>>>>>>> Ganesh Mahendran had backported the series on top of a 4.9 kernel a=
nd gave=0A=
>>>>>>> it a try on an android device. He reported that the application lau=
nch time=0A=
>>>>>>> was improved in average by 6%, and for large applications (~100 thr=
eads) by=0A=
>>>>>>> 20%.=0A=
>>>>>>>=0A=
>>>>>>> Here are the launch time Ganesh mesured on Android 8.0 on top of a =
Qcom=0A=
>>>>>>> MSM845 (8 cores) with 6GB (the less is better):=0A=
>>>>>>>=0A=
>>>>>>> Application                             4.9     4.9+spf delta=0A=
>>>>>>> com.tencent.mm                          416     389     -7%=0A=
>>>>>>> com.eg.android.AlipayGphone             1135    986     -13%=0A=
>>>>>>> com.tencent.mtt                         455     454     0%=0A=
>>>>>>> com.qqgame.hlddz                        1497    1409    -6%=0A=
>>>>>>> com.autonavi.minimap                    711     701     -1%=0A=
>>>>>>> com.tencent.tmgp.sgame                  788     748     -5%=0A=
>>>>>>> com.immomo.momo                         501     487     -3%=0A=
>>>>>>> com.tencent.peng                        2145    2112    -2%=0A=
>>>>>>> com.smile.gifmaker                      491     461     -6%=0A=
>>>>>>> com.baidu.BaiduMap                      479     366     -23%=0A=
>>>>>>> com.taobao.taobao                       1341    1198    -11%=0A=
>>>>>>> com.baidu.searchbox                     333     314     -6%=0A=
>>>>>>> com.tencent.mobileqq                    394     384     -3%=0A=
>>>>>>> com.sina.weibo                          907     906     0%=0A=
>>>>>>> com.youku.phone                         816     731     -11%=0A=
>>>>>>> com.happyelements.AndroidAnimal.qq      763     717     -6%=0A=
>>>>>>> com.UCMobile                            415     411     -1%=0A=
>>>>>>> com.tencent.tmgp.ak                     1464    1431    -2%=0A=
>>>>>>> com.tencent.qqmusic                     336     329     -2%=0A=
>>>>>>> com.sankuai.meituan                     1661    1302    -22%=0A=
>>>>>>> com.netease.cloudmusic                  1193    1200    1%=0A=
>>>>>>> air.tv.douyu.android                    4257    4152    -2%=0A=
>>>>>>>=0A=
>>>>>>> ------------------=0A=
>>>>>>> Benchmarks results=0A=
>>>>>>>=0A=
>>>>>>> Base kernel is v4.17.0-rc4-mm1=0A=
>>>>>>> SPF is BASE + this series=0A=
>>>>>>>=0A=
>>>>>>> Kernbench:=0A=
>>>>>>> ----------=0A=
>>>>>>> Here are the results on a 16 CPUs X86 guest using kernbench on a 4.=
15=0A=
>>>>>>> kernel (kernel is build 5 times):=0A=
>>>>>>>=0A=
>>>>>>> Average Half load -j 8=0A=
>>>>>>>                  Run    (std deviation)=0A=
>>>>>>>                  BASE                   SPF=0A=
>>>>>>> Elapsed Time     1448.65 (5.72312)      1455.84 (4.84951)       0.5=
0%=0A=
>>>>>>> User    Time     10135.4 (30.3699)      10148.8 (31.1252)       0.1=
3%=0A=
>>>>>>> System  Time     900.47  (2.81131)      923.28  (7.52779)       2.5=
3%=0A=
>>>>>>> Percent CPU      761.4   (1.14018)      760.2   (0.447214)      -0.=
16%=0A=
>>>>>>> Context Switches 85380   (3419.52)      84748   (1904.44)       -0.=
74%=0A=
>>>>>>> Sleeps           105064  (1240.96)      105074  (337.612)       0.0=
1%=0A=
>>>>>>>=0A=
>>>>>>> Average Optimal load -j 16=0A=
>>>>>>>                  Run    (std deviation)=0A=
>>>>>>>                  BASE                   SPF=0A=
>>>>>>> Elapsed Time     920.528 (10.1212)      927.404 (8.91789)       0.7=
5%=0A=
>>>>>>> User    Time     11064.8 (981.142)      11085   (990.897)       0.1=
8%=0A=
>>>>>>> System  Time     979.904 (84.0615)      1001.14 (82.5523)       2.1=
7%=0A=
>>>>>>> Percent CPU      1089.5  (345.894)      1086.1  (343.545)       -0.=
31%=0A=
>>>>>>> Context Switches 159488  (78156.4)      158223  (77472.1)       -0.=
79%=0A=
>>>>>>> Sleeps           110566  (5877.49)      110388  (5617.75)       -0.=
16%=0A=
>>>>>>>=0A=
>>>>>>>=0A=
>>>>>>> During a run on the SPF, perf events were captured:=0A=
>>>>>>>  Performance counter stats for '../kernbench -M':=0A=
>>>>>>>          526743764      faults=0A=
>>>>>>>                210      spf=0A=
>>>>>>>                  3      pagefault:spf_vma_changed=0A=
>>>>>>>                  0      pagefault:spf_vma_noanon=0A=
>>>>>>>               2278      pagefault:spf_vma_notsup=0A=
>>>>>>>                  0      pagefault:spf_vma_access=0A=
>>>>>>>                  0      pagefault:spf_pmd_changed=0A=
>>>>>>>=0A=
>>>>>>> Very few speculative page faults were recorded as most of the proce=
sses=0A=
>>>>>>> involved are monothreaded (sounds that on this architecture some th=
reads=0A=
>>>>>>> were created during the kernel build processing).=0A=
>>>>>>>=0A=
>>>>>>> Here are the kerbench results on a 80 CPUs Power8 system:=0A=
>>>>>>>=0A=
>>>>>>> Average Half load -j 40=0A=
>>>>>>>                  Run    (std deviation)=0A=
>>>>>>>                  BASE                   SPF=0A=
>>>>>>> Elapsed Time     117.152 (0.774642)     117.166 (0.476057)      0.0=
1%=0A=
>>>>>>> User    Time     4478.52 (24.7688)      4479.76 (9.08555)       0.0=
3%=0A=
>>>>>>> System  Time     131.104 (0.720056)     134.04  (0.708414)      2.2=
4%=0A=
>>>>>>> Percent CPU      3934    (19.7104)      3937.2  (19.0184)       0.0=
8%=0A=
>>>>>>> Context Switches 92125.4 (576.787)      92581.6 (198.622)       0.5=
0%=0A=
>>>>>>> Sleeps           317923  (652.499)      318469  (1255.59)       0.1=
7%=0A=
>>>>>>>=0A=
>>>>>>> Average Optimal load -j 80=0A=
>>>>>>>                  Run    (std deviation)=0A=
>>>>>>>                  BASE                   SPF=0A=
>>>>>>> Elapsed Time     107.73  (0.632416)     107.31  (0.584936)      -0.=
39%=0A=
>>>>>>> User    Time     5869.86 (1466.72)      5871.71 (1467.27)       0.0=
3%=0A=
>>>>>>> System  Time     153.728 (23.8573)      157.153 (24.3704)       2.2=
3%=0A=
>>>>>>> Percent CPU      5418.6  (1565.17)      5436.7  (1580.91)       0.3=
3%=0A=
>>>>>>> Context Switches 223861  (138865)       225032  (139632)        0.5=
2%=0A=
>>>>>>> Sleeps           330529  (13495.1)      332001  (14746.2)       0.4=
5%=0A=
>>>>>>>=0A=
>>>>>>> During a run on the SPF, perf events were captured:=0A=
>>>>>>>  Performance counter stats for '../kernbench -M':=0A=
>>>>>>>          116730856      faults=0A=
>>>>>>>                  0      spf=0A=
>>>>>>>                  3      pagefault:spf_vma_changed=0A=
>>>>>>>                  0      pagefault:spf_vma_noanon=0A=
>>>>>>>                476      pagefault:spf_vma_notsup=0A=
>>>>>>>                  0      pagefault:spf_vma_access=0A=
>>>>>>>                  0      pagefault:spf_pmd_changed=0A=
>>>>>>>=0A=
>>>>>>> Most of the processes involved are monothreaded so SPF is not activ=
ated but=0A=
>>>>>>> there is no impact on the performance.=0A=
>>>>>>>=0A=
>>>>>>> Ebizzy:=0A=
>>>>>>> -------=0A=
>>>>>>> The test is counting the number of records per second it can manage=
, the=0A=
>>>>>>> higher is the best. I run it like this 'ebizzy -mTt <nrcpus>'. To g=
et=0A=
>>>>>>> consistent result I repeated the test 100 times and measure the ave=
rage=0A=
>>>>>>> result. The number is the record processes per second, the higher i=
s the=0A=
>>>>>>> best.=0A=
>>>>>>>=0A=
>>>>>>>                 BASE            SPF             delta=0A=
>>>>>>> 16 CPUs x86 VM  742.57          1490.24         100.69%=0A=
>>>>>>> 80 CPUs P8 node 13105.4         24174.23        84.46%=0A=
>>>>>>>=0A=
>>>>>>> Here are the performance counter read during a run on a 16 CPUs x86=
 VM:=0A=
>>>>>>>  Performance counter stats for './ebizzy -mTt 16':=0A=
>>>>>>>            1706379      faults=0A=
>>>>>>>            1674599      spf=0A=
>>>>>>>              30588      pagefault:spf_vma_changed=0A=
>>>>>>>                  0      pagefault:spf_vma_noanon=0A=
>>>>>>>                363      pagefault:spf_vma_notsup=0A=
>>>>>>>                  0      pagefault:spf_vma_access=0A=
>>>>>>>                  0      pagefault:spf_pmd_changed=0A=
>>>>>>>=0A=
>>>>>>> And the ones captured during a run on a 80 CPUs Power node:=0A=
>>>>>>>  Performance counter stats for './ebizzy -mTt 80':=0A=
>>>>>>>            1874773      faults=0A=
>>>>>>>            1461153      spf=0A=
>>>>>>>             413293      pagefault:spf_vma_changed=0A=
>>>>>>>                  0      pagefault:spf_vma_noanon=0A=
>>>>>>>                200      pagefault:spf_vma_notsup=0A=
>>>>>>>                  0      pagefault:spf_vma_access=0A=
>>>>>>>                  0      pagefault:spf_pmd_changed=0A=
>>>>>>>=0A=
>>>>>>> In ebizzy's case most of the page fault were handled in a speculati=
ve way,=0A=
>>>>>>> leading the ebizzy performance boost.=0A=
>>>>>>>=0A=
>>>>>>> ------------------=0A=
>>>>>>> Changes since v10 (https://lkml.org/lkml/2018/4/17/572):=0A=
>>>>>>>  - Accounted for all review feedbacks from Punit Agrawal, Ganesh Ma=
hendran=0A=
>>>>>>>    and Minchan Kim, hopefully.=0A=
>>>>>>>  - Remove unneeded check on CONFIG_SPECULATIVE_PAGE_FAULT in=0A=
>>>>>>>    __do_page_fault().=0A=
>>>>>>>  - Loop in pte_spinlock() and pte_map_lock() when pte try lock fail=
s=0A=
>>>>>>>    instead=0A=
>>>>>>>    of aborting the speculative page fault handling. Dropping the no=
w=0A=
>>>>>>> useless=0A=
>>>>>>>    trace event pagefault:spf_pte_lock.=0A=
>>>>>>>  - No more try to reuse the fetched VMA during the speculative page=
 fault=0A=
>>>>>>>    handling when retrying is needed. This adds a lot of complexity =
and=0A=
>>>>>>>    additional tests done didn't show a significant performance impr=
ovement.=0A=
>>>>>>>  - Convert IS_ENABLED(CONFIG_NUMA) back to #ifdef due to build erro=
r.=0A=
>>>>>>>=0A=
>>>>>>> [1] http://linux-kernel.2935.n7.nabble.com/RFC-PATCH-0-6-Another-go=
-at-speculative-page-faults-tt965642.html#none=0A=
>>>>>>> [2] https://patchwork.kernel.org/patch/9999687/=0A=
>>>>>>>=0A=
>>>>>>>=0A=
>>>>>>> Laurent Dufour (20):=0A=
>>>>>>>   mm: introduce CONFIG_SPECULATIVE_PAGE_FAULT=0A=
>>>>>>>   x86/mm: define ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT=0A=
>>>>>>>   powerpc/mm: set ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT=0A=
>>>>>>>   mm: introduce pte_spinlock for FAULT_FLAG_SPECULATIVE=0A=
>>>>>>>   mm: make pte_unmap_same compatible with SPF=0A=
>>>>>>>   mm: introduce INIT_VMA()=0A=
>>>>>>>   mm: protect VMA modifications using VMA sequence count=0A=
>>>>>>>   mm: protect mremap() against SPF hanlder=0A=
>>>>>>>   mm: protect SPF handler against anon_vma changes=0A=
>>>>>>>   mm: cache some VMA fields in the vm_fault structure=0A=
>>>>>>>   mm/migrate: Pass vm_fault pointer to migrate_misplaced_page()=0A=
>>>>>>>   mm: introduce __lru_cache_add_active_or_unevictable=0A=
>>>>>>>   mm: introduce __vm_normal_page()=0A=
>>>>>>>   mm: introduce __page_add_new_anon_rmap()=0A=
>>>>>>>   mm: protect mm_rb tree with a rwlock=0A=
>>>>>>>   mm: adding speculative page fault failure trace events=0A=
>>>>>>>   perf: add a speculative page fault sw event=0A=
>>>>>>>   perf tools: add support for the SPF perf event=0A=
>>>>>>>   mm: add speculative page fault vmstats=0A=
>>>>>>>   powerpc/mm: add speculative page fault=0A=
>>>>>>>=0A=
>>>>>>> Mahendran Ganesh (2):=0A=
>>>>>>>   arm64/mm: define ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT=0A=
>>>>>>>   arm64/mm: add speculative page fault=0A=
>>>>>>>=0A=
>>>>>>> Peter Zijlstra (4):=0A=
>>>>>>>   mm: prepare for FAULT_FLAG_SPECULATIVE=0A=
>>>>>>>   mm: VMA sequence count=0A=
>>>>>>>   mm: provide speculative fault infrastructure=0A=
>>>>>>>   x86/mm: add speculative pagefault handling=0A=
>>>>>>>=0A=
>>>>>>>  arch/arm64/Kconfig                    |   1 +=0A=
>>>>>>>  arch/arm64/mm/fault.c                 |  12 +=0A=
>>>>>>>  arch/powerpc/Kconfig                  |   1 +=0A=
>>>>>>>  arch/powerpc/mm/fault.c               |  16 +=0A=
>>>>>>>  arch/x86/Kconfig                      |   1 +=0A=
>>>>>>>  arch/x86/mm/fault.c                   |  27 +-=0A=
>>>>>>>  fs/exec.c                             |   2 +-=0A=
>>>>>>>  fs/proc/task_mmu.c                    |   5 +-=0A=
>>>>>>>  fs/userfaultfd.c                      |  17 +-=0A=
>>>>>>>  include/linux/hugetlb_inline.h        |   2 +-=0A=
>>>>>>>  include/linux/migrate.h               |   4 +-=0A=
>>>>>>>  include/linux/mm.h                    | 136 +++++++-=0A=
>>>>>>>  include/linux/mm_types.h              |   7 +=0A=
>>>>>>>  include/linux/pagemap.h               |   4 +-=0A=
>>>>>>>  include/linux/rmap.h                  |  12 +-=0A=
>>>>>>>  include/linux/swap.h                  |  10 +-=0A=
>>>>>>>  include/linux/vm_event_item.h         |   3 +=0A=
>>>>>>>  include/trace/events/pagefault.h      |  80 +++++=0A=
>>>>>>>  include/uapi/linux/perf_event.h       |   1 +=0A=
>>>>>>>  kernel/fork.c                         |   5 +-=0A=
>>>>>>>  mm/Kconfig                            |  22 ++=0A=
>>>>>>>  mm/huge_memory.c                      |   6 +-=0A=
>>>>>>>  mm/hugetlb.c                          |   2 +=0A=
>>>>>>>  mm/init-mm.c                          |   3 +=0A=
>>>>>>>  mm/internal.h                         |  20 ++=0A=
>>>>>>>  mm/khugepaged.c                       |   5 +=0A=
>>>>>>>  mm/madvise.c                          |   6 +-=0A=
>>>>>>>  mm/memory.c                           | 612 ++++++++++++++++++++++=
+++++++-----=0A=
>>>>>>>  mm/mempolicy.c                        |  51 ++-=0A=
>>>>>>>  mm/migrate.c                          |   6 +-=0A=
>>>>>>>  mm/mlock.c                            |  13 +-=0A=
>>>>>>>  mm/mmap.c                             | 229 ++++++++++---=0A=
>>>>>>>  mm/mprotect.c                         |   4 +-=0A=
>>>>>>>  mm/mremap.c                           |  13 +=0A=
>>>>>>>  mm/nommu.c                            |   2 +-=0A=
>>>>>>>  mm/rmap.c                             |   5 +-=0A=
>>>>>>>  mm/swap.c                             |   6 +-=0A=
>>>>>>>  mm/swap_state.c                       |   8 +-=0A=
>>>>>>>  mm/vmstat.c                           |   5 +-=0A=
>>>>>>>  tools/include/uapi/linux/perf_event.h |   1 +=0A=
>>>>>>>  tools/perf/util/evsel.c               |   1 +=0A=
>>>>>>>  tools/perf/util/parse-events.c        |   4 +=0A=
>>>>>>>  tools/perf/util/parse-events.l        |   1 +=0A=
>>>>>>>  tools/perf/util/python.c              |   1 +=0A=
>>>>>>>  44 files changed, 1161 insertions(+), 211 deletions(-)=0A=
>>>>>>>  create mode 100644 include/trace/events/pagefault.h=0A=
>>>>>>>=0A=
>>>>>>> --=0A=
>>>>>>> 2.7.4=0A=
>>>>>>>=0A=
>>>>>>>=0A=
>>>>>>=0A=
>>>>>=0A=
>>>>=0A=
>>>=0A=
>>>=0A=
>>=0A=
>=0A=
=0A=

--_004_9FE19350E8A7EE45B64D8D63D368C8966B876B94SHSMSX101ccrcor_
Content-Type: application/gzip;
	name="perf-profile_page_fault3_head_thp_always.gz"
Content-Description: perf-profile_page_fault3_head_thp_always.gz
Content-Disposition: attachment;
	filename="perf-profile_page_fault3_head_thp_always.gz"; size=12909;
	creation-date="Fri, 03 Aug 2018 06:44:15 GMT";
	modification-date="Fri, 03 Aug 2018 06:44:15 GMT"
Content-Transfer-Encoding: base64

H4sIAGGXYVsAA9Rda4/bRrL9Pr+CwMLYewGPrG4+RHngD14nSIzNC7GDexfBosGhKIl3+DIf88hm
//tWnSYpUSNZZI+d+M4i3BGHp7q6+lR1VXdT/ov1qv25+IsVBkXdlNHKyjOLfl5a/0O/v242liUs
IV4K56VwLTkXPj27jYJVVFq3UVnF9PhLS9DNVVAHVr5eV1GtBdiOLbv7VfxbZFn6vphLz5OO79Ef
11FQD0D4o7vUzeRVnQVpRLeTm+KyukkunargtvLKKqMkCir+mzMTi9n8sgydyzQVl/O5FPJyEywC
f7m0r+npIirXe8rS8/6sDOVs463nK9uhJ4Iy3NJf7n1Pefw5K8OiqcgUSZxxE2Ipd3eD2yBO+pt0
axVVIX2eey9cV9+JV/T5myhrCP42q6Pkuffcd5/z83VeB4mVRmlePtBDi6WQjr0Q0rr5G2PTVdvk
C+ryi+soC7dpUN5UL7gTuFDPw7xcWZcfrMtgY11ellGQ1HEavRLWZWpJ16N7Yd5k9Ssx5x/buoys
8CFMouplUViXufWiTgvIZ3kzDNDlV5Z+msC6bf6vKsMX13H2IrqNsvrFXRDXVkGDcllHVU0Pcqt5
UxM/5hYpj6dIdYzZq12Tz63nFlnklfUvy/GX8jlfbVwdXF1cPVwXuPq4Lum6nM9xFbhKXG1cHVxd
XD1cF7j6uAIrgBXACmAFsAJYAawAVgArgBXASmAlsBJYCawEVgIrgZXASmAlsDawNrA2sDawNrA2
sDawNrA2sDawDrAOsA6wDrAOsA6wDrAOsA6wDrAusC6wLrAusC6wLrAusC6wLrAusB6wHrAesB6w
HrAesB6wHrAesB6wC2AXwC6AXQC7AHYB7ALYBbALYBfA+sD6wPrA+sD6wPrA+sD6wPrA+sAugV0C
C14twasleLUEr5bg1RK8WoJXS+aVO2de0VXgKnG1cXVwdXH1cF3g6uMKrABWACuAFcAKYAWwAlgB
rABWACuBlcBKYCWwElgJrARWAiuBlcDawNrA2sDawNrA2sDawNrA2sDawDrAOsA6wDrAOsA6wDrA
OsA6wDrAusC6wLrAusC6wLrAusC6wLrAusB6wHrAesB6wHrAesB6wHrAesB6wC6AXQC7AHYB7ALY
BbALYBfALoBdAOsD6wPrA+vb1r+f65noFYUsuvcvqwrSIokUxcE4Xz3vPq7L6IP1b35KB9D+D/VD
weC3P/3+/u1X9N/3X//+5vV337359vXbH36nO29++uU5xedgpdZ5mdLURs9+9dxaxVVwnUQcAkmf
ONtSc7X+UFA0j6tIxQV9ln1D8UoFSaIfie7DhOYYtWk46r7CZHsQaldNmj68/PabvUhL/YWVfFjJ
h5V8WMmHlXxYaQkrLWGlJay0hIWXwC6BXQK7BHYJLDxIwIMEPEjAgwQ8SMCDBDxIwIMEPEjAgwQ8
SMCDBDwII0FXYOFBAh4k4EECHiTgQQIeJOBBAh4k4EECHiTgQQIeJOBBAh4k4EECHiTgQQIeJOBB
Ah4k4EECHiTgQQIeJOBBAh4k4EECHiTgQQIeJOBBAh4k4EECHiTgQQIeJOBBAh4k4EECHiTgQQIe
JOBBAh4k4EECHiTgQQIeJOBBAh4k4EECHiTgQQIeJOBBAh4k4EECHiTgQQIeJOBBAh4k4EECHiTg
QQIeJOBBAh4k4EHCBxa8EuCVAK8EeCXAKwFeCfBKgFcCvBLglQCvBHglwCsBXgnwSoBXEryS4JUE
ryR4JcErCV5J8EqCVxK8kuCVBK8keCXBKwleSfBKglcSvJLglQSvJHglwSsJXknwSoJXEryS4JUE
ryR4JcErCV5J8EqCVxK8kuCVBK8keCXBKwleSfBKglcSvJLglQSvJHglwSsJXknwSoJXEryS4JUE
ryR4JcErCV5J8EqCVxK8kuCVBK8keCXBKwleSfBKglcSvJLglQSvJHglwSsJXknwSoJXEryS4JUE
r+TC5UjbBksxjLlhnq3jDX2a3y+/iAicpkGhfwvzNG1DbsZPqzxT0X0U6nt1UN203Xkco1mI3Enp
YRSqSSP1/seffvzux2/+QS2vc11AcAPPrYYqmMu3VBSwhkUSPBDgh1++fz0NUaSNRQoUcbapXhKC
Cg5VcPdoxJqMqoVIhdtACZ5iFv2tuCyUTbeYDVW+ru+Csh2vfYxDt5ihHSgNlctP7USndlPEas7C
5QAr2SKOP2iQdXB3OqQyxS0xRApG2v6gVVaVXXfvMZ+fcoZtsh7O8DHB92xvIA2N7qDcA5iHelrk
d1TcMvUGUjwWcqDmkhtzd4LjXLG92Puaosyv2Z7UWaoI+cEBlp+zhy2IBT9lD8SxIdixw6oOanos
xxixo14Ty2+KnEabHxkagXsytDs35x00x+PoiINxhBWGOrD5ONDUZRBGXYtDS2D0h1aXPGAcpfa0
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
NDf+/amTnC6VK+W5/+3PdNW/AAeviHUaWgEA

--_004_9FE19350E8A7EE45B64D8D63D368C8966B876B94SHSMSX101ccrcor_
Content-Type: application/gzip;
	name="perf-profile_page_fault3_head_thp_never.gz"
Content-Description: perf-profile_page_fault3_head_thp_never.gz
Content-Disposition: attachment;
	filename="perf-profile_page_fault3_head_thp_never.gz"; size=12535;
	creation-date="Fri, 03 Aug 2018 06:44:15 GMT";
	modification-date="Fri, 03 Aug 2018 06:44:15 GMT"
Content-Transfer-Encoding: base64

H4sIAA4hY1sAA9RdaY/bRrb93r+CwMCY9wC3rCqucsMfPE6QBJMNYwd4gyAosClK4mtu5tLLLP/9
3XuKokQ12yKrnYlfByFEiufy1q1zl1oo/8l60/1d/MmKwrJpq3htFblFf6+tD7vWettuLUtawn0t
7NeOa8mlCOjeXRyu48q6jas6odtfW4IursMmtIrNpo4bLcB2bLm/Xif/iC1LXxdLd7lceYFHX27i
sBmA+EthC/2Yom7yMIvpcnpTXtY36aVTl/ysoraqOI3Dmr9zFsJfLC+ryLnMMnG5XEohL7ehHwar
lX1Nd5dxtTlSlu4PFlUkF1tvs1zbDt0RVtGOvrkPPOXxeV5FZVuTKdIk50eIlTxcDW/DJO0v0qV1
XEd0vvReua6+kqzp/Js4bwn+Xd7E6UvvZeC+5PuboglTK4uzonqgm/yVkI7tC2nd/IWx2bp75Ctq
8qvrOI92WVjd1K+4EThQy6OiWluXH63LcGtdXlZxmDZJFr8R1mVmSdeja1HR5s0bseQ/27qMregh
SuP6dVlal4X1qslKyGd5C3TQ5VeWvpvA+tn8f11Fr66T/FV8G+fNq7swaaySOuWyieuGbuSnFm1j
CbG0SHncRaqjz94cHvnSemmRRd5Y/7ScYCVf8tHG0cHRxdHD0ccxwHFFx9VyiaPAUeJo4+jg6OLo
4ejjGOAIrABWACuAFcAKYAWwAlgBrABWACuBlcBKYCWwElgJrARWAiuBlcDawNrA2sDawNrA2sDa
wNrA2sDawDrAOsA6wDrAOsA6wDrAOsA6wDrAusC6wLrAusC6wLrAusC6wLrAusB6wHrAesB6wHrA
esB6wHrAesB6wPrA+sD6wPrA+sD6wPrA+sD6wPrABsAGwAbABsAGwAbABsAGwAbABsCugF0BC16t
wKsVeLUCr1bg1Qq8WoFXK+YVRaAljgJHiaONo4Oji6OHo49jgCOwAlgBrABWACuAFcAKYAWwAlgB
rARWAiuBlcBKYCWwElgJrARWAmsDawNrA2sDawNrA2sDawNrA2sD6wDrAOsA6wDrAOsA6wDrAOsA
6wDrAusC6wLrAusC6wLrAusC6wLrAusB6wHrAesB6wHrAesB6wHrAesB6wPrA+sD6wPrA+sD6wPr
A+sD6wMbABsAGwAb2Na/X+pM9IZCFl37p1WHWZnGiuJgUqxf7k83VfzR+jffpQNo/0XzUDL4u5//
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

--_004_9FE19350E8A7EE45B64D8D63D368C8966B876B94SHSMSX101ccrcor_
Content-Type: application/gzip;
	name="perf-profile_page_fault2_head_thp_never.gz"
Content-Description: perf-profile_page_fault2_head_thp_never.gz
Content-Disposition: attachment;
	filename="perf-profile_page_fault2_head_thp_never.gz"; size=11782;
	creation-date="Fri, 03 Aug 2018 06:44:47 GMT";
	modification-date="Fri, 03 Aug 2018 06:44:47 GMT"
Content-Transfer-Encoding: base64

H4sIAJTkYVsAA9Rda4/bRrL9Pr+CwMLYewGPrG4+RFnwB68TJMbmhdjBvYsgaHAoSsMdvszHPLLZ
/75Vp0lKlDQWm37EO0EIieKprq4+VV1d3ZL/Yr1o/y7+YoVBUTdltLbyzKK/59b/0euXzdayhCW8
5479XPiWnAufnr2OgnVUWrdRWcX0+HNL0M11UAdWvtlUUa0F2I4tu/tV/HtkWfq+v5hLf7lw6LNN
FNQDDH1mS2fucSN5VWdBGtHd5Ka4rG6SS6cquKW8ssooiYKKP3NmYjGbX5ahc5mm4nI+l0JeboNF
4C+X9hU9XUTlZk9Vet6flaGcbb3NfG2zFkEZXtMn976nPH6flWHRVGSIJM64CbGUu7vBbRAn/U26
tY6qkN7PvWeuq+/Ea3r/TZQ1BH+d1VHy1Hvqu0/5+Tqvg8RKozQvH+ihxVJIx14Iad38jbHpum3y
GXX52VWUhddpUN5Uz7gTuFDPw7xcW5fvrMtga11ellGQ1HEavRDWZWpJ16N7Yd5k9Qsx5z/buoys
8CFMoup5UViXufWsTgvIZ3kzDM/lV5Z+msC6bf6/KsNnV3H2LLqNsvrZXRDXVkGDcllHVU0Pcqt5
U1tCzC1SHk+R6hizF7smn1pPLbLIC+tfluMv5VO+2rg6uLq4ergucPVxXdJ1OZ/jKnCVuNq4Ori6
uHq4LnD1cQVWACuAFcAKYAWwAlgBrABWACuAlcBKYCWwElgJrARWAiuBlcBKYG1gbWBtYG1gbWBt
YG1gbWBtYG1gHWAdYB1gHWAdYB1gHWAdYB1gHWBdYF1gXWBdYF1gXWBdYF1gXWBdYD1gPWA9YD1g
PWA9YD1gPWA9YD1gF8AugF0AuwB2AewC2AWwC2AXwC6A9YH1gfWB9YH1gfWB9YH1gfWB9YFdArsE
FrxagldL8GoJXi3BqyV4tQSvlswrd868oqvAVeJq4+rg6uLq4brA1ccVWAGsAFYAK4AVwApgBbAC
WAGsAFYCK4GVwEpgJbASWAmsBFYCK4G1gbWBtYG1gbWBtYG1gbWBtYG1gXWAdYB1gHWAdYB1gHWA
dYB1gHWAdYF1gXWBdYF1gXWBdYF1gXWBdYH1gPWA9YD1gPWA9YD1gPWA9YD1gF0AuwB2AewC2AWw
C2AXwC6AXQC7ANYH1gfWB9a3rX8/1fPQCwpZdO9fVhWkRRIpioNxvn7avd2U0Tvr3/yUDqD9B/VD
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

--_004_9FE19350E8A7EE45B64D8D63D368C8966B876B94SHSMSX101ccrcor_--
