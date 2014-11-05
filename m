Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id CC7156B00A2
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 10:32:00 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id z10so948321pdj.15
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 07:32:00 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id qf6si3317635pab.118.2014.11.05.07.31.58
        for <linux-mm@kvack.org>;
        Wed, 05 Nov 2014 07:31:59 -0800 (PST)
Message-ID: <545A42C4.6070908@intel.com>
Date: Wed, 05 Nov 2014 07:31:16 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Documentation: vm: Add 1GB large page support information
References: <1414771317-5721-1-git-send-email-standby24x7@gmail.com>	<5457C6EA.3080809@intel.com> <CALLJCT0fofgUaswpzt1iBqGS1u+fR8L=umwGpV=RG0SvO9TOJA@mail.gmail.com>
In-Reply-To: <CALLJCT0fofgUaswpzt1iBqGS1u+fR8L=umwGpV=RG0SvO9TOJA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masanari Iida <standby24x7@gmail.com>
Cc: Jonathan Corbet <corbet@lwn.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, lcapitulino@redhat.com

On 11/05/2014 07:21 AM, Masanari Iida wrote:
> Luiz, Dave,
> Thanks for comments.
> 
> I understand that there are some exception cases which doesn't support 1G
> large pages on newer CPUs.
> I like Dave's example, at the same time I would like to add "pdpe1gb flag" in
> the document.
> 
> For example, x86 CPUs normally support 4K and 2M (1G if pdpe1gb flag exist).

Is 1G supported on CPUs that have pdpe1gb and are running a 32-bit kernel?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
