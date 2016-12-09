From: Gerhard Wiesinger <lists@wiesinger.com>
Subject: Re: Still OOM problems with 4.9er kernels
Date: Fri, 9 Dec 2016 08:06:25 +0100
Message-ID: <b3d7a0f3-caa4-91f9-4148-b62cf5e23886@wiesinger.com>
References: <aa4a3217-f94c-0477-b573-796c84255d1e@wiesinger.com>
 <c4ddfc91-7c84-19ed-b69a-18403e7590f9@wiesinger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c4ddfc91-7c84-19ed-b69a-18403e7590f9@wiesinger.com>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>
List-Id: linux-mm.kvack.org

Hello,

same with latest kernel rc, dnf still killed with OOM (but sometimes 
better).

./update.sh: line 40:  1591 Killed                  ${EXE} update ${PARAMS}
(does dnf clean all;dnf update)
Linux database.intern 4.9.0-0.rc8.git2.1.fc26.x86_64 #1 SMP Wed Dec 7 
17:53:29 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux

Updated bug report:
https://bugzilla.redhat.com/show_bug.cgi?id=1314697

Any chance to get it fixed in 4.9.0 release?

Ciao,
Gerhard


On 30.11.2016 08:20, Gerhard Wiesinger wrote:
> Hello,
>
> See also:
> Bug 1314697 - Kernel 4.4.3-300.fc23.x86_64 is not stable inside a KVM VM
> https://bugzilla.redhat.com/show_bug.cgi?id=1314697
>
> Ciao,
> Gerhard
>
>
> On 30.11.2016 08:10, Gerhard Wiesinger wrote:
>> Hello,
>>
>> I'm having out of memory situations with my "low memory" VMs in KVM 
>> under Fedora (Kernel 4.7, 4.8 and also before). They started to get 
>> more and more sensitive to OOM. I recently found the following info:
>>
>> https://marius.bloggt-in-braunschweig.de/2016/11/17/linuxkernel-4-74-8-und-der-oom-killer/ 
>>
>> https://www.spinics.net/lists/linux-mm/msg113661.html
>>
>> Therefore I tried the latest Fedora kernels: 
>> 4.9.0-0.rc6.git2.1.fc26.x86_64
>>
>> But OOM situation is still very easy to reproduce:
>>
>> 1.) VM with 128-384MB under Fedora 25
>>
>> 2.) Having some processes run without any load (e.g. Apache)
>>
>> 3.) run an update with: dnf clean all; dnf update
>>
>> 4.) dnf python process get's killed
>>
>>
>> Please make the VM system working again in Kernel 4.9 and to use swap 
>> again correctly.
>>
>> Thnx.
>>
>> Ciao,
>>
>> Gerhard
>>
>>
>
