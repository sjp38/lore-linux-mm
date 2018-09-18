Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id BBD3A8E0002
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 02:43:04 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id c5-v6so557245plo.2
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 23:43:04 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id i22-v6si17024137pgl.439.2018.09.17.23.43.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Sep 2018 23:43:01 -0700 (PDT)
From: "Song, HaiyanX" <haiyanx.song@intel.com>
Subject: RE: [PATCH v11 00/26] Speculative page faults
Date: Tue, 18 Sep 2018 06:42:30 +0000
Message-ID: <9FE19350E8A7EE45B64D8D63D368C8966B89F75B@SHSMSX101.ccr.corp.intel.com>
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
 <9FE19350E8A7EE45B64D8D63D368C8966B86A721@SHSMSX101.ccr.corp.intel.com>
 <166434ae-ecaf-05d8-3cc7-7aa75bc3737b@linux.vnet.ibm.com>
 <9FE19350E8A7EE45B64D8D63D368C8966B876B4B@SHSMSX101.ccr.corp.intel.com>,<f9bc4701-ef52-d2de-0d72-4b29736cb1eb@linux.vnet.ibm.com>
In-Reply-To: <f9bc4701-ef52-d2de-0d72-4b29736cb1eb@linux.vnet.ibm.com>
Content-Language: en-US
Content-Type: multipart/mixed;
	boundary="_003_9FE19350E8A7EE45B64D8D63D368C8966B89F75BSHSMSX101ccrcor_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "kirill@shutemov.name" <kirill@shutemov.name>, "ak@linux.intel.com" <ak@linux.intel.com>, "dave@stgolabs.net" <dave@stgolabs.net>, "jack@suse.cz" <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "mpe@ellerman.id.au" <mpe@ellerman.id.au>, "paulus@samba.org" <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "sergey.senozhatsky.work@gmail.com" <sergey.senozhatsky.work@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, "Wang, Kemi" <kemi.wang@intel.com>, Daniel
 Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Minchan Kim <minchan@kernel.org>, Punit
 Agrawal <punitagrawal@gmail.com>, vinayak menon <vinayakm.list@gmail.com>, Yang Shi <yang.shi@linux.alibaba.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "haren@linux.vnet.ibm.com" <haren@linux.vnet.ibm.com>, "npiggin@gmail.com" <npiggin@gmail.com>, "bsingharora@gmail.com" <bsingharora@gmail.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "x86@kernel.org" <x86@kernel.org>

--_003_9FE19350E8A7EE45B64D8D63D368C8966B89F75BSHSMSX101ccrcor_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hi Laurent,=0A=
=0A=
I am sorry for replying you so late. =0A=
The previous LKP test for this case are running on the same Intel skylake 4=
s platform, but it need maintain recently. =0A=
So I changed to another test box to run the page_fault3 test case, it is In=
tel skylake 2s platform (nr_cpu: 104, memory: 64G).=0A=
=0A=
I applied your patch to the SPF kernel (commit : a7a8993bfe3ccb54ad468b9f17=
99649e4ad1ff12), then triggered below 2 cases test.=0A=
a)  Turn on the SPF handler by below command, then run page_fault3-thp-alwa=
ys test.=0A=
echo 1 > /proc/sys/vm/speculative_page_fault=0A=
=0A=
b) Turn off the SPF handler by below command, then run page_fault3-thp-alwa=
ys test.=0A=
 echo 0 > /proc/sys/vm/speculative_page_fault=0A=
=0A=
Every test run 3 times, and then get test result and capture perf data. =0A=
Here is average result for will-it-scale.per_thread_ops:                   =
                                      =0A=
                                                                           =
               SPF_turn_off       SPF_turn_on=0A=
page_fault3-THP-Alwasys.will-it-scale.per_thread_ops    31963              =
    26285=0A=
=0A=
Best regards,=0A=
Haiyan Song=0A=
=0A=
________________________________________=0A=
From: owner-linux-mm@kvack.org [owner-linux-mm@kvack.org] on behalf of Laur=
ent Dufour [ldufour@linux.vnet.ibm.com]=0A=
Sent: Wednesday, August 22, 2018 10:23 PM=0A=
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
On 03/08/2018 08:36, Song, HaiyanX wrote:=0A=
> Hi Laurent,=0A=
=0A=
Hi Haiyan,=0A=
=0A=
Sorry for the late answer, I was off a couple of days.=0A=
=0A=
>=0A=
> Thanks for your analysis for the last perf results.=0A=
> Your mentioned ," the major differences at the head of the perf report is=
 the 92% testcase which is weirdly not reported=0A=
> on the head side", which is a bug of 0-day,and it caused the item is not =
counted in perf.=0A=
>=0A=
> I've triggered the test page_fault2 and page_fault3 again only with threa=
d mode of will-it-scale on 0-day (on the same test box,every case tested 3 =
times).=0A=
> I checked the perf report have no above mentioned problem.=0A=
>=0A=
> I have compared them, found some items have difference, such as below cas=
e:=0A=
>        page_fault2-thp-always: handle_mm_fault, base: 45.22%    head: 29.=
41%=0A=
>        page_fault3-thp-always: handle_mm_fault, base: 22.95%    head: 14.=
15%=0A=
=0A=
These would mean that the system spends lees time running handle_mm_fault()=
=0A=
when SPF is in the picture in this 2 cases which is good. This should lead =
to=0A=
better results with the SPF series, and I can't find any values higher on t=
he=0A=
head side.=0A=
=0A=
>=0A=
> So i attached the perf result in mail again, could your have a look again=
 for checking the difference between base and head commit.=0A=
=0A=
I took a close look to all the perf result you sent, but I can't identify a=
ny=0A=
major difference. But the compiler optimization is getting rid of the=0A=
handle_pte_fault() symbol on the base kernel which add complexity to check =
the=0A=
differences.=0A=
=0A=
To get rid of that, I'm proposing that you applied the attached patch to th=
e=0A=
spf kernel. This patch is allowing to turn on/off the SPF handler through=
=0A=
/proc/sys/vm/speculative_page_fault.=0A=
=0A=
This should ease the testing by limiting the reboot and avoid kernel's symb=
ols=0A=
mismatch. Obviously there is still a small overhead due to the check but it=
=0A=
should not be viewable.=0A=
=0A=
With this patch applied you can simply run=0A=
echo 1 > /proc/sys/vm/speculative_page_fault=0A=
to run a test with the speculative page fault handler activated. Or run=0A=
echo 0 > /proc/sys/vm/speculative_page_fault=0A=
to run a test without it.=0A=
=0A=
I'm really sorry to asking that again, but could please run the test=0A=
page_fault3_base_THP-Always with and without SPF and capture the perf outpu=
t.=0A=
=0A=
I think we should focus on that test which showed the biggest regression.=
=0A=
=0A=
Thanks,=0A=
Laurent.=0A=
=0A=
=0A=
>=0A=
> Thanks,=0A=
> Haiyan, Song=0A=
>=0A=
> ________________________________________=0A=
> From: owner-linux-mm@kvack.org [owner-linux-mm@kvack.org] on behalf of La=
urent Dufour [ldufour@linux.vnet.ibm.com]=0A=
> Sent: Tuesday, July 17, 2018 5:36 PM=0A=
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
> On 13/07/2018 05:56, Song, HaiyanX wrote:=0A=
>> Hi Laurent,=0A=
>=0A=
> Hi Haiyan,=0A=
>=0A=
> Thanks a lot for sharing this perf reports.=0A=
>=0A=
> I looked at them closely, and I've to admit that I was not able to found =
a=0A=
> major difference between the base and the head report, except that=0A=
> handle_pte_fault() is no more in-lined in the head one.=0A=
>=0A=
> As expected, __handle_speculative_fault() is never traced since these tes=
ts are=0A=
> dealing with file mapping, not handled in the speculative way.=0A=
>=0A=
> When running these test did you seen a major differences in the test's re=
sult=0A=
> between base and head ?=0A=
>=0A=
> From the number of cycles counted, the biggest difference is page_fault3 =
when=0A=
> run with the THP enabled:=0A=
>                                 BASE            HEAD            Delta=0A=
> page_fault2_base_thp_never      1142252426747   1065866197589   -6.69%=0A=
> page_fault2_base_THP-Alwasys    1124844374523   1076312228927   -4.31%=0A=
> page_fault3_base_thp_never      1099387298152   1134118402345   3.16%=0A=
> page_fault3_base_THP-Always     1059370178101   853985561949    -19.39%=
=0A=
>=0A=
>=0A=
> The very weird thing is the difference of the delta cycles reported betwe=
en=0A=
> thp never and thp always, because the speculative way is aborted when che=
cking=0A=
> for the vma->ops field, which is the same in both case, and the thp is ne=
ver=0A=
> checked. So there is no code covering differnce, on the speculative path,=
=0A=
> between these 2 cases. This leads me to think that there are other intera=
ctions=0A=
> interfering in the measure.=0A=
>=0A=
> Looking at the perf-profile_page_fault3_*_THP-Always, the major differenc=
es at=0A=
> the head of the perf report is the 92% testcase which is weirdly not repo=
rted=0A=
> on the head side :=0A=
>     92.02%    22.33%  page_fault3_processes  [.] testcase=0A=
> 92.02% testcase=0A=
>=0A=
> Then the base reported 37.67% for __do_page_fault() where the head report=
ed=0A=
> 48.41%, but the only difference in this function, between base and head, =
is the=0A=
> call to handle_speculative_fault(). But this is a macro checking for the =
fault=0A=
> flags, and mm->users and then calling __handle_speculative_fault() if nee=
ded.=0A=
> So this can't explain this difference, except if __handle_speculative_fau=
lt()=0A=
> is inlined in __do_page_fault().=0A=
> Is this the case on your build ?=0A=
>=0A=
> Haiyan, do you still have the output of the test to check those numbers t=
oo ?=0A=
>=0A=
> Cheers,=0A=
> Laurent=0A=
>=0A=
>> I attached the perf-profile.gz file for case page_fault2 and page_fault3=
. These files were captured during test the related test case.=0A=
>> Please help to check on these data if it can help you to find the higher=
 change. Thanks.=0A=
>>=0A=
>> File name perf-profile_page_fault2_head_THP-Always.gz, means the perf-pr=
ofile result get from page_fault2=0A=
>>     tested for head commit (a7a8993bfe3ccb54ad468b9f1799649e4ad1ff12) wi=
th THP_always configuration.=0A=
>>=0A=
>> Best regards,=0A=
>> Haiyan Song=0A=
>>=0A=
>> ________________________________________=0A=
>> From: owner-linux-mm@kvack.org [owner-linux-mm@kvack.org] on behalf of L=
aurent Dufour [ldufour@linux.vnet.ibm.com]=0A=
>> Sent: Thursday, July 12, 2018 1:05 AM=0A=
>> To: Song, HaiyanX=0A=
>> Cc: akpm@linux-foundation.org; mhocko@kernel.org; peterz@infradead.org; =
kirill@shutemov.name; ak@linux.intel.com; dave@stgolabs.net; jack@suse.cz; =
Matthew Wilcox; khandual@linux.vnet.ibm.com; aneesh.kumar@linux.vnet.ibm.co=
m; benh@kernel.crashing.org; mpe@ellerman.id.au; paulus@samba.org; Thomas G=
leixner; Ingo Molnar; hpa@zytor.com; Will Deacon; Sergey Senozhatsky; serge=
y.senozhatsky.work@gmail.com; Andrea Arcangeli; Alexei Starovoitov; Wang, K=
emi; Daniel Jordan; David Rientjes; Jerome Glisse; Ganesh Mahendran; Mincha=
n Kim; Punit Agrawal; vinayak menon; Yang Shi; linux-kernel@vger.kernel.org=
; linux-mm@kvack.org; haren@linux.vnet.ibm.com; npiggin@gmail.com; bsinghar=
ora@gmail.com; paulmck@linux.vnet.ibm.com; Tim Chen; linuxppc-dev@lists.ozl=
abs.org; x86@kernel.org=0A=
>> Subject: Re: [PATCH v11 00/26] Speculative page faults=0A=
>>=0A=
>> Hi Haiyan,=0A=
>>=0A=
>> Do you get a chance to capture some performance cycles on your system ?=
=0A=
>> I still can't get these numbers on my hardware.=0A=
>>=0A=
>> Thanks,=0A=
>> Laurent.=0A=
>>=0A=
>> On 04/07/2018 09:51, Laurent Dufour wrote:=0A=
>>> On 04/07/2018 05:23, Song, HaiyanX wrote:=0A=
>>>> Hi Laurent,=0A=
>>>>=0A=
>>>>=0A=
>>>> For the test result on Intel 4s skylake platform (192 CPUs, 768G Memor=
y), the below test cases all were run 3 times.=0A=
>>>> I check the test results, only page_fault3_thread/enable THP have 6% s=
tddev for head commit, other tests have lower stddev.=0A=
>>>=0A=
>>> Repeating the test only 3 times seems a bit too low to me.=0A=
>>>=0A=
>>> I'll focus on the higher change for the moment, but I don't have access=
 to such=0A=
>>> a hardware.=0A=
>>>=0A=
>>> Is possible to provide a diff between base and SPF of the performance c=
ycles=0A=
>>> measured when running page_fault3 and page_fault2 when the 20% change i=
s detected.=0A=
>>>=0A=
>>> Please stay focus on the test case process to see exactly where the ser=
ies is=0A=
>>> impacting.=0A=
>>>=0A=
>>> Thanks,=0A=
>>> Laurent.=0A=
>>>=0A=
>>>>=0A=
>>>> And I did not find other high variation on test case result.=0A=
>>>>=0A=
>>>> a). Enable THP=0A=
>>>> testcase                          base     stddev       change      he=
ad     stddev         metric=0A=
>>>> page_fault3/enable THP           10519      =B1 3%        -20.5%      =
8368      =B16%          will-it-scale.per_thread_ops=0A=
>>>> page_fault2/enalbe THP            8281      =B1 2%        -18.8%      =
6728                   will-it-scale.per_thread_ops=0A=
>>>> brk1/eanble THP                 998475                   -2.2%    9768=
93                   will-it-scale.per_process_ops=0A=
>>>> context_switch1/enable THP      223910                   -1.3%    2209=
30                   will-it-scale.per_process_ops=0A=
>>>> context_switch1/enable THP      233722                   -1.0%    2312=
88                   will-it-scale.per_thread_ops=0A=
>>>>=0A=
>>>> b). Disable THP=0A=
>>>> page_fault3/disable THP          10856                  -23.1%      83=
44                   will-it-scale.per_thread_ops=0A=
>>>> page_fault2/disable THP           8147                  -18.8%      66=
13                   will-it-scale.per_thread_ops=0A=
>>>> brk1/disable THP                   957                    -7.9%      8=
81                   will-it-scale.per_thread_ops=0A=
>>>> context_switch1/disable THP     237006                    -2.2%    231=
907                  will-it-scale.per_thread_ops=0A=
>>>> brk1/disable THP                997317                    -2.0%    977=
778                  will-it-scale.per_process_ops=0A=
>>>> page_fault3/disable THP         467454                    -1.8%    459=
251                  will-it-scale.per_process_ops=0A=
>>>> context_switch1/disable THP     224431                    -1.3%    221=
567                  will-it-scale.per_process_ops=0A=
>>>>=0A=
>>>>=0A=
>>>> Best regards,=0A=
>>>> Haiyan Song=0A=
>>>> ________________________________________=0A=
>>>> From: Laurent Dufour [ldufour@linux.vnet.ibm.com]=0A=
>>>> Sent: Monday, July 02, 2018 4:59 PM=0A=
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
>>>> On 11/06/2018 09:49, Song, HaiyanX wrote:=0A=
>>>>> Hi Laurent,=0A=
>>>>>=0A=
>>>>> Regression test for v11 patch serials have been run, some regression =
is found by LKP-tools (linux kernel performance)=0A=
>>>>> tested on Intel 4s skylake platform. This time only test the cases wh=
ich have been run and found regressions on=0A=
>>>>> V9 patch serials.=0A=
>>>>>=0A=
>>>>> The regression result is sorted by the metric will-it-scale.per_threa=
d_ops.=0A=
>>>>> branch: Laurent-Dufour/Speculative-page-faults/20180520-045126=0A=
>>>>> commit id:=0A=
>>>>>   head commit : a7a8993bfe3ccb54ad468b9f1799649e4ad1ff12=0A=
>>>>>   base commit : ba98a1cdad71d259a194461b3a61471b49b14df1=0A=
>>>>> Benchmark: will-it-scale=0A=
>>>>> Download link: https://github.com/antonblanchard/will-it-scale/tree/m=
aster=0A=
>>>>>=0A=
>>>>> Metrics:=0A=
>>>>>   will-it-scale.per_process_ops=3Dprocesses/nr_cpu=0A=
>>>>>   will-it-scale.per_thread_ops=3Dthreads/nr_cpu=0A=
>>>>>   test box: lkp-skl-4sp1(nr_cpu=3D192,memory=3D768G)=0A=
>>>>> THP: enable / disable=0A=
>>>>> nr_task:100%=0A=
>>>>>=0A=
>>>>> 1. Regressions:=0A=
>>>>>=0A=
>>>>> a). Enable THP=0A=
>>>>> testcase                          base           change      head    =
       metric=0A=
>>>>> page_fault3/enable THP           10519          -20.5%        836    =
  will-it-scale.per_thread_ops=0A=
>>>>> page_fault2/enalbe THP            8281          -18.8%       6728    =
  will-it-scale.per_thread_ops=0A=
>>>>> brk1/eanble THP                 998475           -2.2%     976893    =
  will-it-scale.per_process_ops=0A=
>>>>> context_switch1/enable THP      223910           -1.3%     220930    =
  will-it-scale.per_process_ops=0A=
>>>>> context_switch1/enable THP      233722           -1.0%     231288    =
  will-it-scale.per_thread_ops=0A=
>>>>>=0A=
>>>>> b). Disable THP=0A=
>>>>> page_fault3/disable THP          10856          -23.1%       8344    =
  will-it-scale.per_thread_ops=0A=
>>>>> page_fault2/disable THP           8147          -18.8%       6613    =
  will-it-scale.per_thread_ops=0A=
>>>>> brk1/disable THP                   957           -7.9%        881    =
  will-it-scale.per_thread_ops=0A=
>>>>> context_switch1/disable THP     237006           -2.2%     231907    =
  will-it-scale.per_thread_ops=0A=
>>>>> brk1/disable THP                997317           -2.0%     977778    =
  will-it-scale.per_process_ops=0A=
>>>>> page_fault3/disable THP         467454           -1.8%     459251    =
  will-it-scale.per_process_ops=0A=
>>>>> context_switch1/disable THP     224431           -1.3%     221567    =
  will-it-scale.per_process_ops=0A=
>>>>>=0A=
>>>>> Notes: for the above  values of test result, the higher is better.=0A=
>>>>=0A=
>>>> I tried the same tests on my PowerPC victim VM (1024 CPUs, 11TB) and I=
 can't=0A=
>>>> get reproducible results. The results have huge variation, even on the=
 vanilla=0A=
>>>> kernel, and I can't state on any changes due to that.=0A=
>>>>=0A=
>>>> I tried on smaller node (80 CPUs, 32G), and the tests ran better, but =
I didn't=0A=
>>>> measure any changes between the vanilla and the SPF patched ones:=0A=
>>>>=0A=
>>>> test THP enabled                4.17.0-rc4-mm1  spf             delta=
=0A=
>>>> page_fault3_threads             2697.7          2683.5          -0.53%=
=0A=
>>>> page_fault2_threads             170660.6        169574.1        -0.64%=
=0A=
>>>> context_switch1_threads         6915269.2       6877507.3       -0.55%=
=0A=
>>>> context_switch1_processes       6478076.2       6529493.5       0.79%=
=0A=
>>>> brk1                            243391.2        238527.5        -2.00%=
=0A=
>>>>=0A=
>>>> Tests were run 10 times, no high variation detected.=0A=
>>>>=0A=
>>>> Did you see high variation on your side ? How many times the test were=
 run to=0A=
>>>> compute the average values ?=0A=
>>>>=0A=
>>>> Thanks,=0A=
>>>> Laurent.=0A=
>>>>=0A=
>>>>=0A=
>>>>>=0A=
>>>>> 2. Improvement: not found improvement based on the selected test case=
s.=0A=
>>>>>=0A=
>>>>>=0A=
>>>>> Best regards=0A=
>>>>> Haiyan Song=0A=
>>>>> ________________________________________=0A=
>>>>> From: owner-linux-mm@kvack.org [owner-linux-mm@kvack.org] on behalf o=
f Laurent Dufour [ldufour@linux.vnet.ibm.com]=0A=
>>>>> Sent: Monday, May 28, 2018 4:54 PM=0A=
>>>>> To: Song, HaiyanX=0A=
>>>>> Cc: akpm@linux-foundation.org; mhocko@kernel.org; peterz@infradead.or=
g; kirill@shutemov.name; ak@linux.intel.com; dave@stgolabs.net; jack@suse.c=
z; Matthew Wilcox; khandual@linux.vnet.ibm.com; aneesh.kumar@linux.vnet.ibm=
.com; benh@kernel.crashing.org; mpe@ellerman.id.au; paulus@samba.org; Thoma=
s Gleixner; Ingo Molnar; hpa@zytor.com; Will Deacon; Sergey Senozhatsky; se=
rgey.senozhatsky.work@gmail.com; Andrea Arcangeli; Alexei Starovoitov; Wang=
, Kemi; Daniel Jordan; David Rientjes; Jerome Glisse; Ganesh Mahendran; Min=
chan Kim; Punit Agrawal; vinayak menon; Yang Shi; linux-kernel@vger.kernel.=
org; linux-mm@kvack.org; haren@linux.vnet.ibm.com; npiggin@gmail.com; bsing=
harora@gmail.com; paulmck@linux.vnet.ibm.com; Tim Chen; linuxppc-dev@lists.=
ozlabs.org; x86@kernel.org=0A=
>>>>> Subject: Re: [PATCH v11 00/26] Speculative page faults=0A=
>>>>>=0A=
>>>>> On 28/05/2018 10:22, Haiyan Song wrote:=0A=
>>>>>> Hi Laurent,=0A=
>>>>>>=0A=
>>>>>> Yes, these tests are done on V9 patch.=0A=
>>>>>=0A=
>>>>> Do you plan to give this V11 a run ?=0A=
>>>>>=0A=
>>>>>>=0A=
>>>>>>=0A=
>>>>>> Best regards,=0A=
>>>>>> Haiyan Song=0A=
>>>>>>=0A=
>>>>>> On Mon, May 28, 2018 at 09:51:34AM +0200, Laurent Dufour wrote:=0A=
>>>>>>> On 28/05/2018 07:23, Song, HaiyanX wrote:=0A=
>>>>>>>>=0A=
>>>>>>>> Some regression and improvements is found by LKP-tools(linux kerne=
l performance) on V9 patch series=0A=
>>>>>>>> tested on Intel 4s Skylake platform.=0A=
>>>>>>>=0A=
>>>>>>> Hi,=0A=
>>>>>>>=0A=
>>>>>>> Thanks for reporting this benchmark results, but you mentioned the =
"V9 patch=0A=
>>>>>>> series" while responding to the v11 header series...=0A=
>>>>>>> Were these tests done on v9 or v11 ?=0A=
>>>>>>>=0A=
>>>>>>> Cheers,=0A=
>>>>>>> Laurent.=0A=
>>>>>>>=0A=
>>>>>>>>=0A=
>>>>>>>> The regression result is sorted by the metric will-it-scale.per_th=
read_ops.=0A=
>>>>>>>> Branch: Laurent-Dufour/Speculative-page-faults/20180316-151833 (V9=
 patch series)=0A=
>>>>>>>> Commit id:=0A=
>>>>>>>>     base commit: d55f34411b1b126429a823d06c3124c16283231f=0A=
>>>>>>>>     head commit: 0355322b3577eeab7669066df42c550a56801110=0A=
>>>>>>>> Benchmark suite: will-it-scale=0A=
>>>>>>>> Download link:=0A=
>>>>>>>> https://github.com/antonblanchard/will-it-scale/tree/master/tests=
=0A=
>>>>>>>> Metrics:=0A=
>>>>>>>>     will-it-scale.per_process_ops=3Dprocesses/nr_cpu=0A=
>>>>>>>>     will-it-scale.per_thread_ops=3Dthreads/nr_cpu=0A=
>>>>>>>> test box: lkp-skl-4sp1(nr_cpu=3D192,memory=3D768G)=0A=
>>>>>>>> THP: enable / disable=0A=
>>>>>>>> nr_task: 100%=0A=
>>>>>>>>=0A=
>>>>>>>> 1. Regressions:=0A=
>>>>>>>> a) THP enabled:=0A=
>>>>>>>> testcase                        base            change          he=
ad       metric=0A=
>>>>>>>> page_fault3/ enable THP         10092           -17.5%          83=
23       will-it-scale.per_thread_ops=0A=
>>>>>>>> page_fault2/ enable THP          8300           -17.2%          68=
69       will-it-scale.per_thread_ops=0A=
>>>>>>>> brk1/ enable THP                  957.67         -7.6%           8=
85       will-it-scale.per_thread_ops=0A=
>>>>>>>> page_fault3/ enable THP        172821            -5.3%        1636=
92       will-it-scale.per_process_ops=0A=
>>>>>>>> signal1/ enable THP              9125            -3.2%          88=
34       will-it-scale.per_process_ops=0A=
>>>>>>>>=0A=
>>>>>>>> b) THP disabled:=0A=
>>>>>>>> testcase                        base            change          he=
ad       metric=0A=
>>>>>>>> page_fault3/ disable THP        10107           -19.1%          81=
80       will-it-scale.per_thread_ops=0A=
>>>>>>>> page_fault2/ disable THP         8432           -17.8%          69=
31       will-it-scale.per_thread_ops=0A=
>>>>>>>> context_switch1/ disable THP   215389            -6.8%        2007=
76       will-it-scale.per_thread_ops=0A=
>>>>>>>> brk1/ disable THP                 939.67         -6.6%           8=
77.33    will-it-scale.per_thread_ops=0A=
>>>>>>>> page_fault3/ disable THP       173145            -4.7%        1650=
64       will-it-scale.per_process_ops=0A=
>>>>>>>> signal1/ disable THP             9162            -3.9%          88=
02       will-it-scale.per_process_ops=0A=
>>>>>>>>=0A=
>>>>>>>> 2. Improvements:=0A=
>>>>>>>> a) THP enabled:=0A=
>>>>>>>> testcase                        base            change          he=
ad       metric=0A=
>>>>>>>> malloc1/ enable THP               66.33        +469.8%           3=
83.67    will-it-scale.per_thread_ops=0A=
>>>>>>>> writeseek3/ enable THP          2531             +4.5%          26=
46       will-it-scale.per_thread_ops=0A=
>>>>>>>> signal1/ enable THP              989.33          +2.8%          10=
16       will-it-scale.per_thread_ops=0A=
>>>>>>>>=0A=
>>>>>>>> b) THP disabled:=0A=
>>>>>>>> testcase                        base            change          he=
ad       metric=0A=
>>>>>>>> malloc1/ disable THP              90.33        +417.3%           4=
67.33    will-it-scale.per_thread_ops=0A=
>>>>>>>> read2/ disable THP             58934            +39.2%         820=
60       will-it-scale.per_thread_ops=0A=
>>>>>>>> page_fault1/ disable THP        8607            +36.4%         117=
36       will-it-scale.per_thread_ops=0A=
>>>>>>>> read1/ disable THP            314063            +12.7%        3539=
34       will-it-scale.per_thread_ops=0A=
>>>>>>>> writeseek3/ disable THP         2452            +12.5%          27=
59       will-it-scale.per_thread_ops=0A=
>>>>>>>> signal1/ disable THP             971.33          +5.5%          10=
24       will-it-scale.per_thread_ops=0A=
>>>>>>>>=0A=
>>>>>>>> Notes: for above values in column "change", the higher value means=
 that the related testcase result=0A=
>>>>>>>> on head commit is better than that on base commit for this benchma=
rk.=0A=
>>>>>>>>=0A=
>>>>>>>>=0A=
>>>>>>>> Best regards=0A=
>>>>>>>> Haiyan Song=0A=
>>>>>>>>=0A=
>>>>>>>> ________________________________________=0A=
>>>>>>>> From: owner-linux-mm@kvack.org [owner-linux-mm@kvack.org] on behal=
f of Laurent Dufour [ldufour@linux.vnet.ibm.com]=0A=
>>>>>>>> Sent: Thursday, May 17, 2018 7:06 PM=0A=
>>>>>>>> To: akpm@linux-foundation.org; mhocko@kernel.org; peterz@infradead=
.org; kirill@shutemov.name; ak@linux.intel.com; dave@stgolabs.net; jack@sus=
e.cz; Matthew Wilcox; khandual@linux.vnet.ibm.com; aneesh.kumar@linux.vnet.=
ibm.com; benh@kernel.crashing.org; mpe@ellerman.id.au; paulus@samba.org; Th=
omas Gleixner; Ingo Molnar; hpa@zytor.com; Will Deacon; Sergey Senozhatsky;=
 sergey.senozhatsky.work@gmail.com; Andrea Arcangeli; Alexei Starovoitov; W=
ang, Kemi; Daniel Jordan; David Rientjes; Jerome Glisse; Ganesh Mahendran; =
Minchan Kim; Punit Agrawal; vinayak menon; Yang Shi=0A=
>>>>>>>> Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org; haren@linux.=
vnet.ibm.com; npiggin@gmail.com; bsingharora@gmail.com; paulmck@linux.vnet.=
ibm.com; Tim Chen; linuxppc-dev@lists.ozlabs.org; x86@kernel.org=0A=
>>>>>>>> Subject: [PATCH v11 00/26] Speculative page faults=0A=
>>>>>>>>=0A=
>>>>>>>> This is a port on kernel 4.17 of the work done by Peter Zijlstra t=
o handle=0A=
>>>>>>>> page fault without holding the mm semaphore [1].=0A=
>>>>>>>>=0A=
>>>>>>>> The idea is to try to handle user space page faults without holdin=
g the=0A=
>>>>>>>> mmap_sem. This should allow better concurrency for massively threa=
ded=0A=
>>>>>>>> process since the page fault handler will not wait for other threa=
ds memory=0A=
>>>>>>>> layout change to be done, assuming that this change is done in ano=
ther part=0A=
>>>>>>>> of the process's memory space. This type page fault is named specu=
lative=0A=
>>>>>>>> page fault. If the speculative page fault fails because of a concu=
rrency is=0A=
>>>>>>>> detected or because underlying PMD or PTE tables are not yet alloc=
ating, it=0A=
>>>>>>>> is failing its processing and a classic page fault is then tried.=
=0A=
>>>>>>>>=0A=
>>>>>>>> The speculative page fault (SPF) has to look for the VMA matching =
the fault=0A=
>>>>>>>> address without holding the mmap_sem, this is done by introducing =
a rwlock=0A=
>>>>>>>> which protects the access to the mm_rb tree. Previously this was d=
one using=0A=
>>>>>>>> SRCU but it was introducing a lot of scheduling to process the VMA=
's=0A=
>>>>>>>> freeing operation which was hitting the performance by 20% as repo=
rted by=0A=
>>>>>>>> Kemi Wang [2]. Using a rwlock to protect access to the mm_rb tree =
is=0A=
>>>>>>>> limiting the locking contention to these operations which are expe=
cted to=0A=
>>>>>>>> be in a O(log n) order. In addition to ensure that the VMA is not =
freed in=0A=
>>>>>>>> our back a reference count is added and 2 services (get_vma() and=
=0A=
>>>>>>>> put_vma()) are introduced to handle the reference count. Once a VM=
A is=0A=
>>>>>>>> fetched from the RB tree using get_vma(), it must be later freed u=
sing=0A=
>>>>>>>> put_vma(). I can't see anymore the overhead I got while will-it-sc=
ale=0A=
>>>>>>>> benchmark anymore.=0A=
>>>>>>>>=0A=
>>>>>>>> The VMA's attributes checked during the speculative page fault pro=
cessing=0A=
>>>>>>>> have to be protected against parallel changes. This is done by usi=
ng a per=0A=
>>>>>>>> VMA sequence lock. This sequence lock allows the speculative page =
fault=0A=
>>>>>>>> handler to fast check for parallel changes in progress and to abor=
t the=0A=
>>>>>>>> speculative page fault in that case.=0A=
>>>>>>>>=0A=
>>>>>>>> Once the VMA has been found, the speculative page fault handler wo=
uld check=0A=
>>>>>>>> for the VMA's attributes to verify that the page fault has to be h=
andled=0A=
>>>>>>>> correctly or not. Thus, the VMA is protected through a sequence lo=
ck which=0A=
>>>>>>>> allows fast detection of concurrent VMA changes. If such a change =
is=0A=
>>>>>>>> detected, the speculative page fault is aborted and a *classic* pa=
ge fault=0A=
>>>>>>>> is tried.  VMA sequence lockings are added when VMA attributes whi=
ch are=0A=
>>>>>>>> checked during the page fault are modified.=0A=
>>>>>>>>=0A=
>>>>>>>> When the PTE is fetched, the VMA is checked to see if it has been =
changed,=0A=
>>>>>>>> so once the page table is locked, the VMA is valid, so any other c=
hanges=0A=
>>>>>>>> leading to touching this PTE will need to lock the page table, so =
no=0A=
>>>>>>>> parallel change is possible at this time.=0A=
>>>>>>>>=0A=
>>>>>>>> The locking of the PTE is done with interrupts disabled, this allo=
ws=0A=
>>>>>>>> checking for the PMD to ensure that there is not an ongoing collap=
sing=0A=
>>>>>>>> operation. Since khugepaged is firstly set the PMD to pmd_none and=
 then is=0A=
>>>>>>>> waiting for the other CPU to have caught the IPI interrupt, if the=
 pmd is=0A=
>>>>>>>> valid at the time the PTE is locked, we have the guarantee that th=
e=0A=
>>>>>>>> collapsing operation will have to wait on the PTE lock to move for=
ward.=0A=
>>>>>>>> This allows the SPF handler to map the PTE safely. If the PMD valu=
e is=0A=
>>>>>>>> different from the one recorded at the beginning of the SPF operat=
ion, the=0A=
>>>>>>>> classic page fault handler will be called to handle the operation =
while=0A=
>>>>>>>> holding the mmap_sem. As the PTE lock is done with the interrupts =
disabled,=0A=
>>>>>>>> the lock is done using spin_trylock() to avoid dead lock when hand=
ling a=0A=
>>>>>>>> page fault while a TLB invalidate is requested by another CPU hold=
ing the=0A=
>>>>>>>> PTE.=0A=
>>>>>>>>=0A=
>>>>>>>> In pseudo code, this could be seen as:=0A=
>>>>>>>>     speculative_page_fault()=0A=
>>>>>>>>     {=0A=
>>>>>>>>             vma =3D get_vma()=0A=
>>>>>>>>             check vma sequence count=0A=
>>>>>>>>             check vma's support=0A=
>>>>>>>>             disable interrupt=0A=
>>>>>>>>                   check pgd,p4d,...,pte=0A=
>>>>>>>>                   save pmd and pte in vmf=0A=
>>>>>>>>                   save vma sequence counter in vmf=0A=
>>>>>>>>             enable interrupt=0A=
>>>>>>>>             check vma sequence count=0A=
>>>>>>>>             handle_pte_fault(vma)=0A=
>>>>>>>>                     ..=0A=
>>>>>>>>                     page =3D alloc_page()=0A=
>>>>>>>>                     pte_map_lock()=0A=
>>>>>>>>                             disable interrupt=0A=
>>>>>>>>                                     abort if sequence counter has =
changed=0A=
>>>>>>>>                                     abort if pmd or pte has change=
d=0A=
>>>>>>>>                                     pte map and lock=0A=
>>>>>>>>                             enable interrupt=0A=
>>>>>>>>                     if abort=0A=
>>>>>>>>                        free page=0A=
>>>>>>>>                        abort=0A=
>>>>>>>>                     ...=0A=
>>>>>>>>     }=0A=
>>>>>>>>=0A=
>>>>>>>>     arch_fault_handler()=0A=
>>>>>>>>     {=0A=
>>>>>>>>             if (speculative_page_fault(&vma))=0A=
>>>>>>>>                goto done=0A=
>>>>>>>>     again:=0A=
>>>>>>>>             lock(mmap_sem)=0A=
>>>>>>>>             vma =3D find_vma();=0A=
>>>>>>>>             handle_pte_fault(vma);=0A=
>>>>>>>>             if retry=0A=
>>>>>>>>                unlock(mmap_sem)=0A=
>>>>>>>>                goto again;=0A=
>>>>>>>>     done:=0A=
>>>>>>>>             handle fault error=0A=
>>>>>>>>     }=0A=
>>>>>>>>=0A=
>>>>>>>> Support for THP is not done because when checking for the PMD, we =
can be=0A=
>>>>>>>> confused by an in progress collapsing operation done by khugepaged=
. The=0A=
>>>>>>>> issue is that pmd_none() could be true either if the PMD is not al=
ready=0A=
>>>>>>>> populated or if the underlying PTE are in the way to be collapsed.=
 So we=0A=
>>>>>>>> cannot safely allocate a PMD if pmd_none() is true.=0A=
>>>>>>>>=0A=
>>>>>>>> This series add a new software performance event named 'speculativ=
e-faults'=0A=
>>>>>>>> or 'spf'. It counts the number of successful page fault event hand=
led=0A=
>>>>>>>> speculatively. When recording 'faults,spf' events, the faults one =
is=0A=
>>>>>>>> counting the total number of page fault events while 'spf' is only=
 counting=0A=
>>>>>>>> the part of the faults processed speculatively.=0A=
>>>>>>>>=0A=
>>>>>>>> There are some trace events introduced by this series. They allow=
=0A=
>>>>>>>> identifying why the page faults were not processed speculatively. =
This=0A=
>>>>>>>> doesn't take in account the faults generated by a monothreaded pro=
cess=0A=
>>>>>>>> which directly processed while holding the mmap_sem. This trace ev=
ents are=0A=
>>>>>>>> grouped in a system named 'pagefault', they are:=0A=
>>>>>>>>  - pagefault:spf_vma_changed : if the VMA has been changed in our =
back=0A=
>>>>>>>>  - pagefault:spf_vma_noanon : the vma->anon_vma field was not yet =
set.=0A=
>>>>>>>>  - pagefault:spf_vma_notsup : the VMA's type is not supported=0A=
>>>>>>>>  - pagefault:spf_vma_access : the VMA's access right are not respe=
cted=0A=
>>>>>>>>  - pagefault:spf_pmd_changed : the upper PMD pointer has changed i=
n our=0A=
>>>>>>>>    back.=0A=
>>>>>>>>=0A=
>>>>>>>> To record all the related events, the easier is to run perf with t=
he=0A=
>>>>>>>> following arguments :=0A=
>>>>>>>> $ perf stat -e 'faults,spf,pagefault:*' <command>=0A=
>>>>>>>>=0A=
>>>>>>>> There is also a dedicated vmstat counter showing the number of suc=
cessful=0A=
>>>>>>>> page fault handled speculatively. I can be seen this way:=0A=
>>>>>>>> $ grep speculative_pgfault /proc/vmstat=0A=
>>>>>>>>=0A=
>>>>>>>> This series builds on top of v4.16-mmotm-2018-04-13-17-28 and is f=
unctional=0A=
>>>>>>>> on x86, PowerPC and arm64.=0A=
>>>>>>>>=0A=
>>>>>>>> ---------------------=0A=
>>>>>>>> Real Workload results=0A=
>>>>>>>>=0A=
>>>>>>>> As mentioned in previous email, we did non official runs using a "=
popular=0A=
>>>>>>>> in memory multithreaded database product" on 176 cores SMT8 Power =
system=0A=
>>>>>>>> which showed a 30% improvements in the number of transaction proce=
ssed per=0A=
>>>>>>>> second. This run has been done on the v6 series, but changes intro=
duced in=0A=
>>>>>>>> this new version should not impact the performance boost seen.=0A=
>>>>>>>>=0A=
>>>>>>>> Here are the perf data captured during 2 of these runs on top of t=
he v8=0A=
>>>>>>>> series:=0A=
>>>>>>>>                 vanilla         spf=0A=
>>>>>>>> faults          89.418          101.364         +13%=0A=
>>>>>>>> spf                n/a           97.989=0A=
>>>>>>>>=0A=
>>>>>>>> With the SPF kernel, most of the page fault were processed in a sp=
eculative=0A=
>>>>>>>> way.=0A=
>>>>>>>>=0A=
>>>>>>>> Ganesh Mahendran had backported the series on top of a 4.9 kernel =
and gave=0A=
>>>>>>>> it a try on an android device. He reported that the application la=
unch time=0A=
>>>>>>>> was improved in average by 6%, and for large applications (~100 th=
reads) by=0A=
>>>>>>>> 20%.=0A=
>>>>>>>>=0A=
>>>>>>>> Here are the launch time Ganesh mesured on Android 8.0 on top of a=
 Qcom=0A=
>>>>>>>> MSM845 (8 cores) with 6GB (the less is better):=0A=
>>>>>>>>=0A=
>>>>>>>> Application                             4.9     4.9+spf delta=0A=
>>>>>>>> com.tencent.mm                          416     389     -7%=0A=
>>>>>>>> com.eg.android.AlipayGphone             1135    986     -13%=0A=
>>>>>>>> com.tencent.mtt                         455     454     0%=0A=
>>>>>>>> com.qqgame.hlddz                        1497    1409    -6%=0A=
>>>>>>>> com.autonavi.minimap                    711     701     -1%=0A=
>>>>>>>> com.tencent.tmgp.sgame                  788     748     -5%=0A=
>>>>>>>> com.immomo.momo                         501     487     -3%=0A=
>>>>>>>> com.tencent.peng                        2145    2112    -2%=0A=
>>>>>>>> com.smile.gifmaker                      491     461     -6%=0A=
>>>>>>>> com.baidu.BaiduMap                      479     366     -23%=0A=
>>>>>>>> com.taobao.taobao                       1341    1198    -11%=0A=
>>>>>>>> com.baidu.searchbox                     333     314     -6%=0A=
>>>>>>>> com.tencent.mobileqq                    394     384     -3%=0A=
>>>>>>>> com.sina.weibo                          907     906     0%=0A=
>>>>>>>> com.youku.phone                         816     731     -11%=0A=
>>>>>>>> com.happyelements.AndroidAnimal.qq      763     717     -6%=0A=
>>>>>>>> com.UCMobile                            415     411     -1%=0A=
>>>>>>>> com.tencent.tmgp.ak                     1464    1431    -2%=0A=
>>>>>>>> com.tencent.qqmusic                     336     329     -2%=0A=
>>>>>>>> com.sankuai.meituan                     1661    1302    -22%=0A=
>>>>>>>> com.netease.cloudmusic                  1193    1200    1%=0A=
>>>>>>>> air.tv.douyu.android                    4257    4152    -2%=0A=
>>>>>>>>=0A=
>>>>>>>> ------------------=0A=
>>>>>>>> Benchmarks results=0A=
>>>>>>>>=0A=
>>>>>>>> Base kernel is v4.17.0-rc4-mm1=0A=
>>>>>>>> SPF is BASE + this series=0A=
>>>>>>>>=0A=
>>>>>>>> Kernbench:=0A=
>>>>>>>> ----------=0A=
>>>>>>>> Here are the results on a 16 CPUs X86 guest using kernbench on a 4=
.15=0A=
>>>>>>>> kernel (kernel is build 5 times):=0A=
>>>>>>>>=0A=
>>>>>>>> Average Half load -j 8=0A=
>>>>>>>>                  Run    (std deviation)=0A=
>>>>>>>>                  BASE                   SPF=0A=
>>>>>>>> Elapsed Time     1448.65 (5.72312)      1455.84 (4.84951)       0.=
50%=0A=
>>>>>>>> User    Time     10135.4 (30.3699)      10148.8 (31.1252)       0.=
13%=0A=
>>>>>>>> System  Time     900.47  (2.81131)      923.28  (7.52779)       2.=
53%=0A=
>>>>>>>> Percent CPU      761.4   (1.14018)      760.2   (0.447214)      -0=
.16%=0A=
>>>>>>>> Context Switches 85380   (3419.52)      84748   (1904.44)       -0=
.74%=0A=
>>>>>>>> Sleeps           105064  (1240.96)      105074  (337.612)       0.=
01%=0A=
>>>>>>>>=0A=
>>>>>>>> Average Optimal load -j 16=0A=
>>>>>>>>                  Run    (std deviation)=0A=
>>>>>>>>                  BASE                   SPF=0A=
>>>>>>>> Elapsed Time     920.528 (10.1212)      927.404 (8.91789)       0.=
75%=0A=
>>>>>>>> User    Time     11064.8 (981.142)      11085   (990.897)       0.=
18%=0A=
>>>>>>>> System  Time     979.904 (84.0615)      1001.14 (82.5523)       2.=
17%=0A=
>>>>>>>> Percent CPU      1089.5  (345.894)      1086.1  (343.545)       -0=
.31%=0A=
>>>>>>>> Context Switches 159488  (78156.4)      158223  (77472.1)       -0=
.79%=0A=
>>>>>>>> Sleeps           110566  (5877.49)      110388  (5617.75)       -0=
.16%=0A=
>>>>>>>>=0A=
>>>>>>>>=0A=
>>>>>>>> During a run on the SPF, perf events were captured:=0A=
>>>>>>>>  Performance counter stats for '../kernbench -M':=0A=
>>>>>>>>          526743764      faults=0A=
>>>>>>>>                210      spf=0A=
>>>>>>>>                  3      pagefault:spf_vma_changed=0A=
>>>>>>>>                  0      pagefault:spf_vma_noanon=0A=
>>>>>>>>               2278      pagefault:spf_vma_notsup=0A=
>>>>>>>>                  0      pagefault:spf_vma_access=0A=
>>>>>>>>                  0      pagefault:spf_pmd_changed=0A=
>>>>>>>>=0A=
>>>>>>>> Very few speculative page faults were recorded as most of the proc=
esses=0A=
>>>>>>>> involved are monothreaded (sounds that on this architecture some t=
hreads=0A=
>>>>>>>> were created during the kernel build processing).=0A=
>>>>>>>>=0A=
>>>>>>>> Here are the kerbench results on a 80 CPUs Power8 system:=0A=
>>>>>>>>=0A=
>>>>>>>> Average Half load -j 40=0A=
>>>>>>>>                  Run    (std deviation)=0A=
>>>>>>>>                  BASE                   SPF=0A=
>>>>>>>> Elapsed Time     117.152 (0.774642)     117.166 (0.476057)      0.=
01%=0A=
>>>>>>>> User    Time     4478.52 (24.7688)      4479.76 (9.08555)       0.=
03%=0A=
>>>>>>>> System  Time     131.104 (0.720056)     134.04  (0.708414)      2.=
24%=0A=
>>>>>>>> Percent CPU      3934    (19.7104)      3937.2  (19.0184)       0.=
08%=0A=
>>>>>>>> Context Switches 92125.4 (576.787)      92581.6 (198.622)       0.=
50%=0A=
>>>>>>>> Sleeps           317923  (652.499)      318469  (1255.59)       0.=
17%=0A=
>>>>>>>>=0A=
>>>>>>>> Average Optimal load -j 80=0A=
>>>>>>>>                  Run    (std deviation)=0A=
>>>>>>>>                  BASE                   SPF=0A=
>>>>>>>> Elapsed Time     107.73  (0.632416)     107.31  (0.584936)      -0=
.39%=0A=
>>>>>>>> User    Time     5869.86 (1466.72)      5871.71 (1467.27)       0.=
03%=0A=
>>>>>>>> System  Time     153.728 (23.8573)      157.153 (24.3704)       2.=
23%=0A=
>>>>>>>> Percent CPU      5418.6  (1565.17)      5436.7  (1580.91)       0.=
33%=0A=
>>>>>>>> Context Switches 223861  (138865)       225032  (139632)        0.=
52%=0A=
>>>>>>>> Sleeps           330529  (13495.1)      332001  (14746.2)       0.=
45%=0A=
>>>>>>>>=0A=
>>>>>>>> During a run on the SPF, perf events were captured:=0A=
>>>>>>>>  Performance counter stats for '../kernbench -M':=0A=
>>>>>>>>          116730856      faults=0A=
>>>>>>>>                  0      spf=0A=
>>>>>>>>                  3      pagefault:spf_vma_changed=0A=
>>>>>>>>                  0      pagefault:spf_vma_noanon=0A=
>>>>>>>>                476      pagefault:spf_vma_notsup=0A=
>>>>>>>>                  0      pagefault:spf_vma_access=0A=
>>>>>>>>                  0      pagefault:spf_pmd_changed=0A=
>>>>>>>>=0A=
>>>>>>>> Most of the processes involved are monothreaded so SPF is not acti=
vated but=0A=
>>>>>>>> there is no impact on the performance.=0A=
>>>>>>>>=0A=
>>>>>>>> Ebizzy:=0A=
>>>>>>>> -------=0A=
>>>>>>>> The test is counting the number of records per second it can manag=
e, the=0A=
>>>>>>>> higher is the best. I run it like this 'ebizzy -mTt <nrcpus>'. To =
get=0A=
>>>>>>>> consistent result I repeated the test 100 times and measure the av=
erage=0A=
>>>>>>>> result. The number is the record processes per second, the higher =
is the=0A=
>>>>>>>> best.=0A=
>>>>>>>>=0A=
>>>>>>>>                 BASE            SPF             delta=0A=
>>>>>>>> 16 CPUs x86 VM  742.57          1490.24         100.69%=0A=
>>>>>>>> 80 CPUs P8 node 13105.4         24174.23        84.46%=0A=
>>>>>>>>=0A=
>>>>>>>> Here are the performance counter read during a run on a 16 CPUs x8=
6 VM:=0A=
>>>>>>>>  Performance counter stats for './ebizzy -mTt 16':=0A=
>>>>>>>>            1706379      faults=0A=
>>>>>>>>            1674599      spf=0A=
>>>>>>>>              30588      pagefault:spf_vma_changed=0A=
>>>>>>>>                  0      pagefault:spf_vma_noanon=0A=
>>>>>>>>                363      pagefault:spf_vma_notsup=0A=
>>>>>>>>                  0      pagefault:spf_vma_access=0A=
>>>>>>>>                  0      pagefault:spf_pmd_changed=0A=
>>>>>>>>=0A=
>>>>>>>> And the ones captured during a run on a 80 CPUs Power node:=0A=
>>>>>>>>  Performance counter stats for './ebizzy -mTt 80':=0A=
>>>>>>>>            1874773      faults=0A=
>>>>>>>>            1461153      spf=0A=
>>>>>>>>             413293      pagefault:spf_vma_changed=0A=
>>>>>>>>                  0      pagefault:spf_vma_noanon=0A=
>>>>>>>>                200      pagefault:spf_vma_notsup=0A=
>>>>>>>>                  0      pagefault:spf_vma_access=0A=
>>>>>>>>                  0      pagefault:spf_pmd_changed=0A=
>>>>>>>>=0A=
>>>>>>>> In ebizzy's case most of the page fault were handled in a speculat=
ive way,=0A=
>>>>>>>> leading the ebizzy performance boost.=0A=
>>>>>>>>=0A=
>>>>>>>> ------------------=0A=
>>>>>>>> Changes since v10 (https://lkml.org/lkml/2018/4/17/572):=0A=
>>>>>>>>  - Accounted for all review feedbacks from Punit Agrawal, Ganesh M=
ahendran=0A=
>>>>>>>>    and Minchan Kim, hopefully.=0A=
>>>>>>>>  - Remove unneeded check on CONFIG_SPECULATIVE_PAGE_FAULT in=0A=
>>>>>>>>    __do_page_fault().=0A=
>>>>>>>>  - Loop in pte_spinlock() and pte_map_lock() when pte try lock fai=
ls=0A=
>>>>>>>>    instead=0A=
>>>>>>>>    of aborting the speculative page fault handling. Dropping the n=
ow=0A=
>>>>>>>> useless=0A=
>>>>>>>>    trace event pagefault:spf_pte_lock.=0A=
>>>>>>>>  - No more try to reuse the fetched VMA during the speculative pag=
e fault=0A=
>>>>>>>>    handling when retrying is needed. This adds a lot of complexity=
 and=0A=
>>>>>>>>    additional tests done didn't show a significant performance imp=
rovement.=0A=
>>>>>>>>  - Convert IS_ENABLED(CONFIG_NUMA) back to #ifdef due to build err=
or.=0A=
>>>>>>>>=0A=
>>>>>>>> [1] http://linux-kernel.2935.n7.nabble.com/RFC-PATCH-0-6-Another-g=
o-at-speculative-page-faults-tt965642.html#none=0A=
>>>>>>>> [2] https://patchwork.kernel.org/patch/9999687/=0A=
>>>>>>>>=0A=
>>>>>>>>=0A=
>>>>>>>> Laurent Dufour (20):=0A=
>>>>>>>>   mm: introduce CONFIG_SPECULATIVE_PAGE_FAULT=0A=
>>>>>>>>   x86/mm: define ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT=0A=
>>>>>>>>   powerpc/mm: set ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT=0A=
>>>>>>>>   mm: introduce pte_spinlock for FAULT_FLAG_SPECULATIVE=0A=
>>>>>>>>   mm: make pte_unmap_same compatible with SPF=0A=
>>>>>>>>   mm: introduce INIT_VMA()=0A=
>>>>>>>>   mm: protect VMA modifications using VMA sequence count=0A=
>>>>>>>>   mm: protect mremap() against SPF hanlder=0A=
>>>>>>>>   mm: protect SPF handler against anon_vma changes=0A=
>>>>>>>>   mm: cache some VMA fields in the vm_fault structure=0A=
>>>>>>>>   mm/migrate: Pass vm_fault pointer to migrate_misplaced_page()=0A=
>>>>>>>>   mm: introduce __lru_cache_add_active_or_unevictable=0A=
>>>>>>>>   mm: introduce __vm_normal_page()=0A=
>>>>>>>>   mm: introduce __page_add_new_anon_rmap()=0A=
>>>>>>>>   mm: protect mm_rb tree with a rwlock=0A=
>>>>>>>>   mm: adding speculative page fault failure trace events=0A=
>>>>>>>>   perf: add a speculative page fault sw event=0A=
>>>>>>>>   perf tools: add support for the SPF perf event=0A=
>>>>>>>>   mm: add speculative page fault vmstats=0A=
>>>>>>>>   powerpc/mm: add speculative page fault=0A=
>>>>>>>>=0A=
>>>>>>>> Mahendran Ganesh (2):=0A=
>>>>>>>>   arm64/mm: define ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT=0A=
>>>>>>>>   arm64/mm: add speculative page fault=0A=
>>>>>>>>=0A=
>>>>>>>> Peter Zijlstra (4):=0A=
>>>>>>>>   mm: prepare for FAULT_FLAG_SPECULATIVE=0A=
>>>>>>>>   mm: VMA sequence count=0A=
>>>>>>>>   mm: provide speculative fault infrastructure=0A=
>>>>>>>>   x86/mm: add speculative pagefault handling=0A=
>>>>>>>>=0A=
>>>>>>>>  arch/arm64/Kconfig                    |   1 +=0A=
>>>>>>>>  arch/arm64/mm/fault.c                 |  12 +=0A=
>>>>>>>>  arch/powerpc/Kconfig                  |   1 +=0A=
>>>>>>>>  arch/powerpc/mm/fault.c               |  16 +=0A=
>>>>>>>>  arch/x86/Kconfig                      |   1 +=0A=
>>>>>>>>  arch/x86/mm/fault.c                   |  27 +-=0A=
>>>>>>>>  fs/exec.c                             |   2 +-=0A=
>>>>>>>>  fs/proc/task_mmu.c                    |   5 +-=0A=
>>>>>>>>  fs/userfaultfd.c                      |  17 +-=0A=
>>>>>>>>  include/linux/hugetlb_inline.h        |   2 +-=0A=
>>>>>>>>  include/linux/migrate.h               |   4 +-=0A=
>>>>>>>>  include/linux/mm.h                    | 136 +++++++-=0A=
>>>>>>>>  include/linux/mm_types.h              |   7 +=0A=
>>>>>>>>  include/linux/pagemap.h               |   4 +-=0A=
>>>>>>>>  include/linux/rmap.h                  |  12 +-=0A=
>>>>>>>>  include/linux/swap.h                  |  10 +-=0A=
>>>>>>>>  include/linux/vm_event_item.h         |   3 +=0A=
>>>>>>>>  include/trace/events/pagefault.h      |  80 +++++=0A=
>>>>>>>>  include/uapi/linux/perf_event.h       |   1 +=0A=
>>>>>>>>  kernel/fork.c                         |   5 +-=0A=
>>>>>>>>  mm/Kconfig                            |  22 ++=0A=
>>>>>>>>  mm/huge_memory.c                      |   6 +-=0A=
>>>>>>>>  mm/hugetlb.c                          |   2 +=0A=
>>>>>>>>  mm/init-mm.c                          |   3 +=0A=
>>>>>>>>  mm/internal.h                         |  20 ++=0A=
>>>>>>>>  mm/khugepaged.c                       |   5 +=0A=
>>>>>>>>  mm/madvise.c                          |   6 +-=0A=
>>>>>>>>  mm/memory.c                           | 612 +++++++++++++++++++++=
++++++++-----=0A=
>>>>>>>>  mm/mempolicy.c                        |  51 ++-=0A=
>>>>>>>>  mm/migrate.c                          |   6 +-=0A=
>>>>>>>>  mm/mlock.c                            |  13 +-=0A=
>>>>>>>>  mm/mmap.c                             | 229 ++++++++++---=0A=
>>>>>>>>  mm/mprotect.c                         |   4 +-=0A=
>>>>>>>>  mm/mremap.c                           |  13 +=0A=
>>>>>>>>  mm/nommu.c                            |   2 +-=0A=
>>>>>>>>  mm/rmap.c                             |   5 +-=0A=
>>>>>>>>  mm/swap.c                             |   6 +-=0A=
>>>>>>>>  mm/swap_state.c                       |   8 +-=0A=
>>>>>>>>  mm/vmstat.c                           |   5 +-=0A=
>>>>>>>>  tools/include/uapi/linux/perf_event.h |   1 +=0A=
>>>>>>>>  tools/perf/util/evsel.c               |   1 +=0A=
>>>>>>>>  tools/perf/util/parse-events.c        |   4 +=0A=
>>>>>>>>  tools/perf/util/parse-events.l        |   1 +=0A=
>>>>>>>>  tools/perf/util/python.c              |   1 +=0A=
>>>>>>>>  44 files changed, 1161 insertions(+), 211 deletions(-)=0A=
>>>>>>>>  create mode 100644 include/trace/events/pagefault.h=0A=
>>>>>>>>=0A=
>>>>>>>> --=0A=
>>>>>>>> 2.7.4=0A=
>>>>>>>>=0A=
>>>>>>>>=0A=
>>>>>>>=0A=
>>>>>>=0A=
>>>>>=0A=
>>>>=0A=
>>>>=0A=
>>>=0A=
>>=0A=
>=0A=
=0A=

--_003_9FE19350E8A7EE45B64D8D63D368C8966B89F75BSHSMSX101ccrcor_
Content-Type: application/gzip;
	name="perf-profile_page_fault3-head-thp-always-SPF-off.gz"
Content-Description: perf-profile_page_fault3-head-thp-always-SPF-off.gz
Content-Disposition: attachment;
	filename="perf-profile_page_fault3-head-thp-always-SPF-off.gz"; size=11278;
	creation-date="Tue, 18 Sep 2018 06:34:25 GMT";
	modification-date="Tue, 18 Sep 2018 06:34:25 GMT"
Content-Transfer-Encoding: base64

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

--_003_9FE19350E8A7EE45B64D8D63D368C8966B89F75BSHSMSX101ccrcor_
Content-Type: application/gzip;
	name="perf-profile_page_fault3-head-thp-always-SPF-on.gz"
Content-Description: perf-profile_page_fault3-head-thp-always-SPF-on.gz
Content-Disposition: attachment;
	filename="perf-profile_page_fault3-head-thp-always-SPF-on.gz"; size=11424;
	creation-date="Tue, 18 Sep 2018 06:34:37 GMT";
	modification-date="Tue, 18 Sep 2018 06:34:37 GMT"
Content-Transfer-Encoding: base64

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
JyECC6UMdHLKnf7tW1r1f3KRBodTNAEA

--_003_9FE19350E8A7EE45B64D8D63D368C8966B89F75BSHSMSX101ccrcor_--
