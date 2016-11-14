Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id CC6D16B0069
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 14:35:02 -0500 (EST)
Received: by mail-pa0-f69.google.com with SMTP id ro13so96889057pac.7
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 11:35:02 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b189si23367376pgc.333.2016.11.14.11.35.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Nov 2016 11:35:02 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAEJXXse092470
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 14:35:01 -0500
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26qjus26kg-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 14:35:01 -0500
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Mon, 14 Nov 2016 12:35:00 -0700
Date: Mon, 14 Nov 2016 13:34:52 -0600
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/4] of/fdt: mark hotpluggable memory
References: <1478562276-25539-1-git-send-email-arbab@linux.vnet.ibm.com>
 <1478562276-25539-5-git-send-email-arbab@linux.vnet.ibm.com>
 <87bmxii85s.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <87bmxii85s.fsf@concordia.ellerman.id.au>
Message-Id: <20161114193451.bzowsi6csesoxwap@arbab-laptop.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, devicetree@vger.kernel.org, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org

On Mon, Nov 14, 2016 at 10:59:43PM +1100, Michael Ellerman wrote:
>So I'm not opposed to this, but it is a little vague.
>
>What does the "hotpluggable" property really mean?
>
>Is it just a hint to the operating system? (which may or may not be
>Linux).
>
>Or is it a direction, "this memory must be able to be hotunplugged"?
>
>I think you're intending the former, ie. a hint, which is probably OK.
>But it needs to be documented clearly.

Yes, you've got it right. It's just a hint, not a mandate.

I'm about to send v7 which adds a description of "hotpluggable" in the 
documentation. Hopefully I've explained it well enough there.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
