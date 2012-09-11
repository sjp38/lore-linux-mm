Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id B0D876B0075
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 21:19:22 -0400 (EDT)
Message-ID: <504E92EF.3050303@cn.fujitsu.com>
Date: Tue, 11 Sep 2012 09:25:03 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC v8 PATCH 00/20] memory-hotplug: hot-remove physical memory
References: <1346148027-24468-1-git-send-email-wency@cn.fujitsu.com>	<20120831134956.fec0f681.akpm@linux-foundation.org>	<504D467D.2080201@jp.fujitsu.com>	<504D4A08.7090602@cn.fujitsu.com>	<20120910135213.GA1550@dhcp-192-168-178-175.profitbricks.localdomain> <CAAV+Mu7YWRWnxt78F4ZDMrrUsWB=n-_qkYOcQT7WQ2HwP89Obw@mail.gmail.com>
In-Reply-To: <CAAV+Mu7YWRWnxt78F4ZDMrrUsWB=n-_qkYOcQT7WQ2HwP89Obw@mail.gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerry <uulinux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com

At 09/11/2012 08:27 AM, Jerry Wrote:
> Hi Wen,
> 
> I have been arranged a job related memory hotplug on ARM architecture.
> Maybe I know some new issues about memory hotplug on ARM architecture. I
> just enabled it on ARM, and it works well in my Android tablet now.
> However, I have not send out my patches. The real reason is that I don't
> know how to do it. Maybe I need to read "Documentation/SubmittingPatches".
> 
> Hi Andrew,
> This is my first time to send you a e-mail. I am so nervous about if I have
> some mistakes or not.
> 
> Some peoples maybe think memory hotplug need to be supported by special
> hardware. Maybe it means memory physical hotplug. Some times, we just need
> to use memory logical hotplug, doesn't remove the memory in physical. It is
> also usefully for power saving in my platform. Because I doesn't want
> the offline memory is in *self-refresh* state.

Power saving? Do you need _PSx support?

Thanks
Wen Congyang

> 
> Any comments are appreciated.
> 
> Thanks,
> Jerry
> 
> 2012/9/10 Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
> 
>> Hi,
>>
>> On Mon, Sep 10, 2012 at 10:01:44AM +0800, Wen Congyang wrote:
>>> At 09/10/2012 09:46 AM, Yasuaki Ishimatsu Wrote:
>>>> Hi Wen,
>>>>
>>>> 2012/09/01 5:49, Andrew Morton wrote:
>>>>> On Tue, 28 Aug 2012 18:00:07 +0800
>>>>> wency@cn.fujitsu.com wrote:
>>>>>
>>>>>> This patch series aims to support physical memory hot-remove.
>>>>>
>>>>> I doubt if many people have hardware which permits physical memory
>>>>> removal?  How would you suggest that people with regular hardware can
>>>>> test these chagnes?
>>>>
>>>> How do you test the patch? As Andrew says, for hot-removing memory,
>>>> we need a particular hardware. I think so too. So many people may want
>>>> to know how to test the patch.
>>>> If we apply following patch to kvm guest, can we hot-remove memory on
>>>> kvm guest?
>>>>
>>>> http://lists.gnu.org/archive/html/qemu-devel/2012-07/msg01389.html
>>>
>>> Yes, if we apply this patchset, we can test hot-remove memory on kvm
>> guest.
>>> But that patchset doesn't implement _PS3, so there is some restriction.
>>
>> the following repos contain the patchset above, plus 2 more patches that
>> add
>> PS3 support to the dimm devices in qemu/seabios:
>>
>> https://github.com/vliaskov/seabios/commits/memhp-v2
>> https://github.com/vliaskov/qemu-kvm/commits/memhp-v2
>>
>> I have not posted the PS3 patches yet in the qemu list, but will post them
>> soon for v3 of the memory hotplug series. If you have issues testing, let
>> me
>> know.
>>
>> thanks,
>>
>> - Vasilis
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
