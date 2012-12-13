Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 3D3536B002B
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 10:15:24 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so1531760pbc.14
        for <linux-mm@kvack.org>; Thu, 13 Dec 2012 07:15:23 -0800 (PST)
Message-ID: <50C9F0F5.40307@gmail.com>
Date: Thu, 13 Dec 2012 23:15:01 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 0/3] acpi: Introduce prepare_remove device operation
References: <1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com>       <50B5EFE9.3040206@huawei.com>      <1354128096.26955.276.camel@misato.fc.hp.com>     <50B6E936.2080308@huawei.com>  <1354228028.7776.56.camel@misato.fc.hp.com>     <50BC29C6.6050706@huawei.com>   <1354579848.21585.54.camel@misato.fc.hp.com>  <50C0CA90.7010608@gmail.com>   <1354849065.21116.61.camel@misato.fc.hp.com> <50C1852D.3000104@huawei.com>  <1354928933.28379.37.camel@misato.fc.hp.com> <50C74481.7010107@gmail.com> <1355409749.18964.107.camel@misato.fc.hp.com>
In-Reply-To: <1355409749.18964.107.camel@misato.fc.hp.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Hanjun Guo <guohanjun@huawei.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, lenb@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tang Chen <tangchen@cn.fujitsu.com>, Huxinwei <huxinwei@huawei.com>

On 12/13/2012 10:42 PM, Toshi Kani wrote:
> On Tue, 2012-12-11 at 22:34 +0800, Jiang Liu wrote:
>> On 12/08/2012 09:08 AM, Toshi Kani wrote:
>>> On Fri, 2012-12-07 at 13:57 +0800, Jiang Liu wrote:
>>>> On 2012-12-7 10:57, Toshi Kani wrote:
>>>>> On Fri, 2012-12-07 at 00:40 +0800, Jiang Liu wrote:
>>>>>> On 12/04/2012 08:10 AM, Toshi Kani wrote:
>>>>>>> On Mon, 2012-12-03 at 12:25 +0800, Hanjun Guo wrote:
>>>>>>>> On 2012/11/30 6:27, Toshi Kani wrote:
>>>>>>>>> On Thu, 2012-11-29 at 12:48 +0800, Hanjun Guo wrote:
>  :
>>>>> Yes, the framework should allow such future work.  I also think that the
>>>>> framework itself should be independent from such ACPI issue.  Ideally,
>>>>> it should be able to support non-ACPI platforms.
>>>> The same point here. The ACPI based hotplug framework is designed as:
>>>> 1) an ACPI based hotplug slot driver to handle platform specific logic.
>>>>    Platform may provide platform specific slot drivers to discover, manage
>>>>    hotplug slots. We have provided a default implementation of slot driver
>>>>    according to the ACPI spec.
>>>
>>> The ACPI spec does not define that _EJ0 is required to receive a hot-add
>>> request, i.e. bus/device check.  This is a major issue.  Since Windows
>>> only supports hot-add, I think there are platforms that only support
>>> hot-add today.
>>>
>>>> 2) an ACPI based hotplug manager driver, which is a platform independent
>>>>    driver and manages all hotplug slot created by the slot driver.
>>>
>>> It is surely impressive work, but I think is is a bit overdoing.  I
>>> expect hot-pluggable servers come with management console and/or GUI
>>> where a user can manage hardware units and initiate hot-plug operations.
>>> I do not think the kernel needs to step into such area since it tends to
>>> be platform-specific. 
>> One of the major usages of this feature is for testing. 
>> It will be hard for OSVs and OEMs to verify hotplug functionalities if it could
>> only be tested by physical hotplug or through management console. So to pave the
>> way for hotplug, we need to provide a mechanism for OEMs and OSVs to execute 
>> auto stress tests for hotplug functionalities.
> 
> Yes, but such OS->FW interface is platform-specific.  Some platforms use
> IPMI for the OS to communicate with the management console.  In this
> case, an OEM-specific command can be used to request a hotplug through
> IPMI.  Some platforms may also support test programs to run on the
> management console for validations.
> 
> For early development testing, Yinghai's SCI emulation patch can be used
> to emulate hotplug events from the OS.  It would be part of the kernel
> debugging features once this patch is accepted. 
Hi Toshi,
	ACPI 5.0 has provided some mechanism to normalize the way to issue
RAS related requests to firmware. I hope ACPI 5.x will define some standardized
ways based on the PCC defined in 5.0. If needed, we may provide platform
specific methods for them too.
Regards!
Gerry

> 
>  
>>>> We haven't gone further enough to provide an ACPI independent hotplug framework
>>>> because we only have experience with x86 and Itanium, both are ACPI based.
>>>> We may try to implement an ACPI independent hotplug framework by pushing all
>>>> ACPI specific logic into the slot driver, I think it's doable. But we need
>>>> suggestions from experts of other architectures, such as SPARC and Power.
>>>> But seems Power already have some sorts of hotplug framework, right?
>>>
>>> I do not know about the Linux hot-plug support on other architectures.
>>> PA-RISC SuperDome also supports Node hot-plug, but it is not supported
>>> by Linux.  Since ARM is getting used by servers, I would not surprise if
>>> there will be an ARM based server with hot-plug support in future.
>> Seems ARM is on the way to adopt ACPI, so may be we could support ARM servers
>> in the future.
> 
> That's good to know.
> 
>  :
>>>>>> So in our framework, we have an option to relay hotplug event from firmware
>>>>>> to userspace, so the userspace has a chance to reject the hotplug operations
>>>>>> if it may cause unacceptable disturbance to userspace services.
>>>>>
>>>>> I think validation from user-space is necessary for deleting I/O
>>>>> devices.  For CPU and memory, the kernel check works fine.
>>>> Agreed. But we may need help from userspace to handle cgroup/cpuset/cpuisol
>>>> etc for cpu and memory hot-removal. Especially for telecom applications, they
>>>> have strong dependency on cgroup/cpuisol to guarantee latency.
>>>
>>> I have not looked at the code, but isn't these cpu attributes managed in
>>> the kernel?
>> Some Telecom applications want to run in an deterministic environment, so they
>> depend on cpuisol/cpuset to provide such an environment. If hotplug event happens,
>> these Telecom application should be notified so they have a chance to redistribute
>> the workload.
> 
> I agree that we need to generate an event that can be subscribed by
> those applications, so that they can react quickly on the change.
> 
> Thanks,
> -Toshi
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
