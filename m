Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DA2F66B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 11:59:19 -0500 (EST)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id oAIGxFQC008608
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 08:59:15 -0800
Received: from pvc30 (pvc30.prod.google.com [10.241.209.158])
	by wpaz24.hot.corp.google.com with ESMTP id oAIGxBMG008815
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 08:59:14 -0800
Received: by pvc30 with SMTP id 30so876135pvc.28
        for <linux-mm@kvack.org>; Thu, 18 Nov 2010 08:59:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1011171434320.22190@chino.kir.corp.google.com>
References: <20101117020759.016741414@intel.com>
	<20101117021000.916235444@intel.com>
	<1290019807.9173.3789.camel@nimitz>
	<alpine.DEB.2.00.1011171312590.10254@chino.kir.corp.google.com>
	<1290030945.9173.4211.camel@nimitz>
	<alpine.DEB.2.00.1011171434320.22190@chino.kir.corp.google.com>
Date: Thu, 18 Nov 2010 08:59:11 -0800
Message-ID: <AANLkTim3-+qDLbXS+Boa-ziNvKkyc-sXK5j0xVstt7tt@mail.gmail.com>
Subject: Re: [7/8,v3] NUMA Hotplug Emulator: extend memory probe interface to
 support NUMA
From: Aaron Durbin <adurbin@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, shaohui.zheng@intel.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Haicheng Li <haicheng.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Greg KH <greg@kroah.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2010 at 2:44 PM, David Rientjes <rientjes@google.com> wrote=
:
> On Wed, 17 Nov 2010, Dave Hansen wrote:
>
>> > Then, export the amount of memory that is actually physically present =
in
>> > the e820 but was truncated by mem=3D
>>
>> I _think_ that's already effectively done in /sys/firmware/memmap.
>>
>
> Ok.
>
> It's a little complicated because we don't export each online node's
> physical address range so you have to parse the dmesg to find what nodes
> were allocated at boot and determine how much physically present memory
> you have that's hidden but can be hotplugged using the probe files.
>
> Adding Aaron Durbin <adurbin@google.com> to the cc because he has a patch
> that exports the physical address range of each node in their sysfs
> directories.

Is this something that is needed upstream? I can post it if that is the cas=
e.
Sorry, I don't have a lot of context w.r.t. this thread.

>
>> > and allow users to hot-add the memory
>> > via the probe interface. =A0Add a writeable 'node' file to offlined me=
mory
>> > section directories and allow it to be changed prior to online.
>>
>> That would work, in theory. =A0But, in practice, we allocate the mem_map=
[]
>> at probe time. =A0So, we've already effectively picked a node at probe.
>> That was done because the probe is equivalent to the hardware "add"
>> event. =A0Once the hardware where in the address space the memory is, it
>> always also knows the node.
>>
>> But, I guess it also wouldn't be horrible if we just hot-removed and
>> hot-added an offline section if someone did write to a node file like
>> you're suggesting. =A0It might actually exercise some interesting code
>> paths.
>>
>
> Since the pages are offline you should be able to modify the memmap when
> the 'node' file is written and use populate_memnodemap() since that file
> is only writeable in an offline state.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
