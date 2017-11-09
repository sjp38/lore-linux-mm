Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BD912440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 10:34:56 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id u70so4959941pfa.2
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 07:34:56 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id w23si6609912plk.696.2017.11.09.07.34.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Nov 2017 07:34:54 -0800 (PST)
Subject: Re: [PATCH 05/30] x86, kaiser: prepare assembly for entry/exit CR3
 switching
References: <20171108194646.907A1942@viggo.jf.intel.com>
 <20171108194654.B960A09E@viggo.jf.intel.com>
 <20171109132016.ntku742dgppt7k4v@pd.tnic>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <e676a8bb-6966-6c01-d62c-bfbc476d5f3e@linux.intel.com>
Date: Thu, 9 Nov 2017 07:34:52 -0800
MIME-Version: 1.0
In-Reply-To: <20171109132016.ntku742dgppt7k4v@pd.tnic>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On 11/09/2017 05:20 AM, Borislav Petkov wrote:
> What branch is that one against?

It's against Andy's entry rework:

https://git.kernel.org/pub/scm/linux/kernel/git/luto/linux.git/log/?h=x86/entry_consolidation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
