Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DD8256B0038
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 19:10:03 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id j128so500256407pfg.4
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 16:10:03 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id 64si44479509pgj.306.2016.12.26.16.10.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Dec 2016 16:10:02 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id n5so10568491pgh.3
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 16:10:02 -0800 (PST)
Subject: Re: [PATCH v6 4/4] of/fdt: mark hotpluggable memory
References: <1478562276-25539-5-git-send-email-arbab@linux.vnet.ibm.com>
 <20161225090222.3703-1-xypron.glpk@gmx.de>
From: Frank Rowand <frowand.list@gmail.com>
Message-ID: <5861B11E.1050303@gmail.com>
Date: Mon, 26 Dec 2016 16:09:02 -0800
MIME-Version: 1.0
In-Reply-To: <20161225090222.3703-1-xypron.glpk@gmx.de>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heinrich Schuchardt <xypron.glpk@gmx.de>, Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, "H . Peter Anvin" <hpa@zytor.com>, Alistair Popple <apopple@au1.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Stewart Smith <stewart@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 12/25/16 01:02, Heinrich Schuchardt wrote:
> The patch adds a new property "linux,hotpluggable" to memory nodes of the
> device tree.
> 
> memory@0 {
> 	reg = <0x0 0x01000000 0x0 0x7f000000>;
> 	linux,hotpluggable;
> }
> 
> Memory areas marked by this property can later be disabled using the hotplugging
> API. Especially for virtual machines this is a very useful capability.
> 
> Unfortunately the notation chosen does not fit well with the concept of
> devicetree overlays which allow to change the devicetree during runtime.

Why would one want to change the hot pluggable memory node via an overlay?
In other words, what is missing from the hot pluggable memory paradigm
that instead requires overlays?

If something is missing from the hot pluggable memory code, then it seems
to me that it should be added to that code instead of hacking around it
by using device tree overlays.

-Frank

> 
> I suggest to use the following notation
> 
> memory@0 {
> 	compatible = "linux,hotpluggable-memory";
> 	reg = <0x0 0x01000000 0x0 0x7f000000>;
> 	status = "disabled";
> }
> 
> This will allow us to write a device driver that can react to changes of the
> devicetree made via devicetree overlays.
> 
> This driver could react to the change of the status between "okay" and
> "disabled" and update the memory status accordingly.
> 
> Further we could use devicetree overlays to provide additional hotpluggable
> memory.
> 
> The referenced patch has already been pulled for 4.10. But I hope it is not
> too late for this design change.
> 
> Best regards
> 
> Heinrich Schuchardt
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
