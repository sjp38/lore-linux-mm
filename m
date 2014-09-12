Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6B3E46B0035
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 20:51:14 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id p10so12079pdj.30
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 17:51:14 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id v9si4441104pdr.242.2014.09.11.17.51.12
        for <linux-mm@kvack.org>;
        Thu, 11 Sep 2014 17:51:13 -0700 (PDT)
Message-ID: <54124379.5090502@intel.com>
Date: Thu, 11 Sep 2014 17:51:05 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 00/10] Intel MPX support
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/11/2014 01:46 AM, Qiaowei Ren wrote:
> MPX kernel code, namely this patchset, has mainly the 2 responsibilities:
> provide handlers for bounds faults (#BR), and manage bounds memory.

Qiaowei, We probably need to mention here what "bounds memory" is, and
why it has to be managed, and who is responsible for the different pieces.

Who allocates the memory?
Who fills the memory?
When is it freed?

Thomas, do you have any other suggestions for things you'd like to see
clarified?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
