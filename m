Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9F0B76B00B6
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 08:58:03 -0500 (EST)
Received: by mail-qa0-f49.google.com with SMTP id ii20so6291140qab.15
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 05:58:03 -0800 (PST)
Received: from bear.ext.ti.com (bear.ext.ti.com. [192.94.94.41])
        by mx.google.com with ESMTPS id hb10si24104937qeb.84.2013.11.25.05.58.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 25 Nov 2013 05:58:02 -0800 (PST)
Message-ID: <52935762.1080409@ti.com>
Date: Mon, 25 Nov 2013 08:57:54 -0500
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: nobootmem: avoid type warning about alignment value
References: <1385249326-9089-1-git-send-email-santosh.shilimkar@ti.com> <529217C7.6030304@cogentembedded.com>
In-Reply-To: <529217C7.6030304@cogentembedded.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Cc: linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org

On Sunday 24 November 2013 10:14 AM, Sergei Shtylyov wrote:
> Hello.
> 
> On 24-11-2013 3:28, Santosh Shilimkar wrote:
> 
>> Building ARM with NO_BOOTMEM generates below warning. Using min_t
> 
>    Where is that below? :-)
> 
Damn.. Posted a wrong version of the patch ;-(
Here is the one with warning message included.
