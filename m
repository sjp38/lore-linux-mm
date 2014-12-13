Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 784696B006C
	for <linux-mm@kvack.org>; Sat, 13 Dec 2014 06:48:30 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id b13so11115969wgh.31
        for <linux-mm@kvack.org>; Sat, 13 Dec 2014 03:48:29 -0800 (PST)
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id lo2si7204465wjb.27.2014.12.13.03.48.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 13 Dec 2014 03:48:29 -0800 (PST)
Received: by mail-wg0-f48.google.com with SMTP id y19so11031747wgg.7
        for <linux-mm@kvack.org>; Sat, 13 Dec 2014 03:48:29 -0800 (PST)
Date: Sat, 13 Dec 2014 11:48:27 +0000
From: Matt Fleming <matt@console-pimps.org>
Subject: Re: Progress on system crash traces with LTTng using DAX and pmem
Message-ID: <20141213114827.GA7761@console-pimps.org>
References: <1254279794.1957.1414240389301.JavaMail.zimbra@efficios.com>
 <465653369.1985.1414241485934.JavaMail.zimbra@efficios.com>
 <20141028105458.GA9768@node.dhcp.inet.fi>
 <864133911.4806.1414681896478.JavaMail.zimbra@efficios.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <864133911.4806.1414681896478.JavaMail.zimbra@efficios.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, lttng-dev <lttng-dev@lists.lttng.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, linux-efi@vger.kernel.org, Tony Luck <tony.luck@gmail.com>

On Thu, 30 Oct, at 03:11:36PM, Mathieu Desnoyers wrote:
> 
> Hi Kirill,
> 
> This is a good point,
> 
> There are a few more aspects to consider here:
> 
> - Other architectures appear to have different guarantees, for
>   instance ARM which, AFAIK, does not reset memory on soft
>   reboot (well at least for my customer's boards). So I guess
>   if x86 wants to be competitive, it would be good for them to
>   offer a similar feature,
> 
> - Already having a subset of machines supporting this is useful,
>   e.g. storing trace buffers and recovering them after a crash,
> 
> - Since we are in a world of dynamically upgradable BIOS, perhaps
>   if we can show that there is value in having a BIOS option to
>   specify a memory range that should not be reset on soft reboot,
>   BIOS vendors might be inclined to include an option for it,
> 
> - Perhaps UEFI BIOS already have some way of specifying that a
>   memory range should not be reset on soft reboot ?

We've achieved this in the past using UEFI capsules with the
EFI_CAPSULE_PERSIST_ACROSS_RESET header flag.

Unfortunately, runtime capsule support is pretty spotty, so it's not a
general solution right now.

-- 
Matt Fleming, Intel Open Source Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
