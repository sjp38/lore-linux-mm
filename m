Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 857C76B00A0
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 01:34:02 -0400 (EDT)
Message-ID: <504ECEA2.4010805@cn.fujitsu.com>
Date: Tue, 11 Sep 2012 13:39:46 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC v8 PATCH 00/20] memory-hotplug: hot-remove physical memory
References: <1346148027-24468-1-git-send-email-wency@cn.fujitsu.com>	<20120831134956.fec0f681.akpm@linux-foundation.org>	<504D467D.2080201@jp.fujitsu.com>	<504D4A08.7090602@cn.fujitsu.com>	<20120910135213.GA1550@dhcp-192-168-178-175.profitbricks.localdomain>	<CAAV+Mu7YWRWnxt78F4ZDMrrUsWB=n-_qkYOcQT7WQ2HwP89Obw@mail.gmail.com>	<20120911012345.GD14205@bbox> <CAAV+Mu4hb0qbW2Ry6w5FAGUM06puDH0v_H-jr584-G9CzJqSGw@mail.gmail.com>
In-Reply-To: <CAAV+Mu4hb0qbW2Ry6w5FAGUM06puDH0v_H-jr584-G9CzJqSGw@mail.gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerry <uulinux@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, kosaki.motohiro@jp.fujitsu.com

At 09/11/2012 01:18 PM, Jerry Wrote:
> Hi Kim,
> 
> Thank you for your kindness. Let me clarify this:
> 
> On ARM architecture, there are 32 bits physical addresses space. However,
> the addresses space is divided into 8 banks normally. Each bank
> disabled/enabled by a chip selector signal. In my platform, bank0 connects
> a DDR chip, and bank1 also connects another DDR chip. And each DDR chip
> whose capability is 512MB is integrated into the main board. So, it could
> not be removed by hand. We can disable/enable each bank by peripheral
> device controller registers.
> 
> When system enter suspend state, if all the pages allocated could be
> migrated to one bank, there are no valid data in the another bank. In this
> time, I could disable the free bank. It isn't necessary to provided power
> to this chip in the suspend state. When system resume, I just need to
> enable it again.
> 
> Hi Wen,
> 
> I am sorry for that I doesn't know the "_PSx support" means. Maybe I
> needn't it.

Hmm, arm doesn't support ACPI, so please ignore it.

Thanks
Wen Congyang

> 
> Thanks,
> Jerry
> 
> 2012/9/11 Minchan Kim <minchan@kernel.org>
> 
>> Hi Jerry,
>>
>> On Tue, Sep 11, 2012 at 08:27:40AM +0800, Jerry wrote:
>>> Hi Wen,
>>>
>>> I have been arranged a job related memory hotplug on ARM architecture.
>>> Maybe I know some new issues about memory hotplug on ARM architecture. I
>>> just enabled it on ARM, and it works well in my Android tablet now.
>>> However, I have not send out my patches. The real reason is that I don't
>>> know how to do it. Maybe I need to read
>> "Documentation/SubmittingPatches".
>>>
>>> Hi Andrew,
>>> This is my first time to send you a e-mail. I am so nervous about if I
>> have
>>> some mistakes or not.
>>
>> Don't be afraid.
>> If you might make a mistake, it's very natural to newbie.
>> I am sure anyone doesn't blame you. :)
>> If you have a good patch, please send out.
>>
>>>
>>> Some peoples maybe think memory hotplug need to be supported by special
>>> hardware. Maybe it means memory physical hotplug. Some times, we just
>> need
>>> to use memory logical hotplug, doesn't remove the memory in physical. It
>> is
>>> also usefully for power saving in my platform. Because I doesn't want
>>> the offline memory is in *self-refresh* state.
>>
>> Just out of curiosity.
>> What's the your scenario and gain?
>> AFAIK, there were some effort about it in embedded side but gain isn't
>> rather big
>> IIRC.
>>
>>>
>>> Any comments are appreciated.
>>>
>>> Thanks,
>>> Jerry
>>>
>>> 2012/9/10 Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
>>>
>>>> Hi,
>>>>
>>>> On Mon, Sep 10, 2012 at 10:01:44AM +0800, Wen Congyang wrote:
>>>>> At 09/10/2012 09:46 AM, Yasuaki Ishimatsu Wrote:
>>>>>> Hi Wen,
>>>>>>
>>>>>> 2012/09/01 5:49, Andrew Morton wrote:
>>>>>>> On Tue, 28 Aug 2012 18:00:07 +0800
>>>>>>> wency@cn.fujitsu.com wrote:
>>>>>>>
>>>>>>>> This patch series aims to support physical memory hot-remove.
>>>>>>>
>>>>>>> I doubt if many people have hardware which permits physical memory
>>>>>>> removal?  How would you suggest that people with regular hardware
>> can
>>>>>>> test these chagnes?
>>>>>>
>>>>>> How do you test the patch? As Andrew says, for hot-removing memory,
>>>>>> we need a particular hardware. I think so too. So many people may
>> want
>>>>>> to know how to test the patch.
>>>>>> If we apply following patch to kvm guest, can we hot-remove memory
>> on
>>>>>> kvm guest?
>>>>>>
>>>>>> http://lists.gnu.org/archive/html/qemu-devel/2012-07/msg01389.html
>>>>>
>>>>> Yes, if we apply this patchset, we can test hot-remove memory on kvm
>>>> guest.
>>>>> But that patchset doesn't implement _PS3, so there is some
>> restriction.
>>>>
>>>> the following repos contain the patchset above, plus 2 more patches
>> that
>>>> add
>>>> PS3 support to the dimm devices in qemu/seabios:
>>>>
>>>> https://github.com/vliaskov/seabios/commits/memhp-v2
>>>> https://github.com/vliaskov/qemu-kvm/commits/memhp-v2
>>>>
>>>> I have not posted the PS3 patches yet in the qemu list, but will post
>> them
>>>> soon for v3 of the memory hotplug series. If you have issues testing,
>> let
>>>> me
>>>> know.
>>>>
>>>> thanks,
>>>>
>>>> - Vasilis
>>>>
>>>> --
>>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>>> see: http://www.linux-mm.org/ .
>>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>>>
>>>
>>>
>>>
>>> --
>>> I love linux!!!
>>
>> --
>> Kind regards,
>> Minchan Kim
>>
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
