Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3E9616B027B
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 11:39:50 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id p91-v6so5562090plb.12
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 08:39:50 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u75-v6si53185591pfd.328.2018.06.07.08.39.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 08:39:49 -0700 (PDT)
Received: from mail-it0-f46.google.com (mail-it0-f46.google.com [209.85.214.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D49402089E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 15:39:48 +0000 (UTC)
Received: by mail-it0-f46.google.com with SMTP id j186-v6so13188398ita.5
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 08:39:48 -0700 (PDT)
MIME-Version: 1.0
References: <20180607143544.3477-1-yu-cheng.yu@intel.com> <20180607143544.3477-6-yu-cheng.yu@intel.com>
In-Reply-To: <20180607143544.3477-6-yu-cheng.yu@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 7 Jun 2018 08:39:36 -0700
Message-ID: <CALCETrWVZfWUSOy6wRyVBfP2b2TzZuPt8bCe6q0Pa5r7onO+VA@mail.gmail.com>
Subject: Re: [PATCH 5/5] Documentation/x86: Add CET description
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, Jun 7, 2018 at 7:40 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:

Fix the subject line, please.  This is more than just docs.

>
> Explain how CET works and the noshstk/noibt kernel parameters.

Maybe no_cet_shstk and no_cet_ibt?  noshstk sounds like gibberish and
people might need a reminder.
