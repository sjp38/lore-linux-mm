Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8B81C6B0038
	for <linux-mm@kvack.org>; Sat, 31 Jan 2015 01:23:38 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so60849853pad.7
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 22:23:38 -0800 (PST)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id xg13si16329623pac.74.2015.01.30.22.23.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 30 Jan 2015 22:23:37 -0800 (PST)
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YHRSu-001tdr-TF
	for linux-mm@kvack.org; Sat, 31 Jan 2015 06:23:33 +0000
Message-ID: <54CC74DC.3000806@roeck-us.net>
Date: Fri, 30 Jan 2015 22:23:24 -0800
From: Guenter Roeck <linux@roeck-us.net>
MIME-Version: 1.0
Subject: Re: [PATCH 00/19] expose page table levels on Kconfig leve
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com> <20150130172613.GA12367@roeck-us.net> <20150130185052.GA30401@node.dhcp.inet.fi> <20150130191435.GA16823@roeck-us.net> <20150130200956.GB30401@node.dhcp.inet.fi> <20150130205958.GA1124@roeck-us.net> <20150131001141.GA31680@node.dhcp.inet.fi>
In-Reply-To: <20150131001141.GA31680@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/30/2015 04:11 PM, Kirill A. Shutemov wrote:
>
> The patch below should fix all regressions from -next.
> Please test.
>
Here is the current status, with the tip of your config_pgtable_levels
branch plus a couple of fixes addressing most of the build failures
your branch inherited from -next.

Build results:
	total: 134 pass: 133 fail: 1
Failed builds:
	sparc64:allmodconfig
Qemu tests:
	total: 30 pass: 30 fail: 0

The remaining build failure is not related to your patch series.
There are also some WARNING tracebacks in the arm qemu test, but
those are also not related to your series.

Feel free to add

Tested-by: Guenter Roeck <linux@roeck-us.net>

Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
