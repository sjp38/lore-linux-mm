Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 1E1AC6B0044
	for <linux-mm@kvack.org>; Fri, 14 Dec 2012 20:29:03 -0500 (EST)
Message-ID: <1355534397.18964.304.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH v3 0/3] acpi: Introduce prepare_remove device
 operation
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 14 Dec 2012 18:19:57 -0700
In-Reply-To: <50C9F0F5.40307@gmail.com>
References: 
	<1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
	       <50B5EFE9.3040206@huawei.com>
	      <1354128096.26955.276.camel@misato.fc.hp.com>
	     <50B6E936.2080308@huawei.com>
	  <1354228028.7776.56.camel@misato.fc.hp.com>
	     <50BC29C6.6050706@huawei.com>
	   <1354579848.21585.54.camel@misato.fc.hp.com>
	  <50C0CA90.7010608@gmail.com>
	   <1354849065.21116.61.camel@misato.fc.hp.com>
	 <50C1852D.3000104@huawei.com>  <1354928933.28379.37.camel@misato.fc.hp.com>
	 <50C74481.7010107@gmail.com> <1355409749.18964.107.camel@misato.fc.hp.com>
	 <50C9F0F5.40307@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Hanjun Guo <guohanjun@huawei.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, lenb@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tang Chen <tangchen@cn.fujitsu.com>, Huxinwei <huxinwei@huawei.com>

On Thu, 2012-12-13 at 23:15 +0800, Jiang Liu wrote:
> On 12/13/2012 10:42 PM, Toshi Kani wrote:
> > On Tue, 2012-12-11 at 22:34 +0800, Jiang Liu wrote:
> >> On 12/08/2012 09:08 AM, Toshi Kani wrote:
> >>> On Fri, 2012-12-07 at 13:57 +0800, Jiang Liu wrote:
> >>>> On 2012-12-7 10:57, Toshi Kani wrote:
> >>>>> On Fri, 2012-12-07 at 00:40 +0800, Jiang Liu wrote:
 :
> >>>
> >>>> 2) an ACPI based hotplug manager driver, which is a platform independent
> >>>>    driver and manages all hotplug slot created by the slot driver.
> >>>
> >>> It is surely impressive work, but I think is is a bit overdoing.  I
> >>> expect hot-pluggable servers come with management console and/or GUI
> >>> where a user can manage hardware units and initiate hot-plug operations.
> >>> I do not think the kernel needs to step into such area since it tends to
> >>> be platform-specific. 
> >> One of the major usages of this feature is for testing. 
> >> It will be hard for OSVs and OEMs to verify hotplug functionalities if it could
> >> only be tested by physical hotplug or through management console. So to pave the
> >> way for hotplug, we need to provide a mechanism for OEMs and OSVs to execute 
> >> auto stress tests for hotplug functionalities.
> > 
> > Yes, but such OS->FW interface is platform-specific.  Some platforms use
> > IPMI for the OS to communicate with the management console.  In this
> > case, an OEM-specific command can be used to request a hotplug through
> > IPMI.  Some platforms may also support test programs to run on the
> > management console for validations.
> > 
> > For early development testing, Yinghai's SCI emulation patch can be used
> > to emulate hotplug events from the OS.  It would be part of the kernel
> > debugging features once this patch is accepted. 
> Hi Toshi,
> 	ACPI 5.0 has provided some mechanism to normalize the way to issue
> RAS related requests to firmware. I hope ACPI 5.x will define some standardized
> ways based on the PCC defined in 5.0. If needed, we may provide platform
> specific methods for them too.

Thanks for the pointer!  Yeah, the spec purposely does not define the
command.  When we support PCC, we will need to provide a way for user
app or oem module to supply a payload. 

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
