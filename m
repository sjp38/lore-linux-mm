Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C74E76B0005
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 16:18:43 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id w1-v6so3901271pgr.7
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 13:18:43 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id s65-v6si18708626pfe.290.2018.06.07.13.18.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 13:18:42 -0700 (PDT)
Subject: Re: [PATCH 03/10] x86/cet: Signal handling for shadow stack
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
 <20180607143807.3611-4-yu-cheng.yu@intel.com>
 <CALCETrWo77RS_wOzskw5OG-LdC1S-b_NY=uPWUmPbQEnNwANgQ@mail.gmail.com>
 <1528402350.5265.21.camel@2b52.sc.intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <22ccde18-6175-fc57-d1a3-06140b419116@linux.intel.com>
Date: Thu, 7 Jun 2018 13:17:20 -0700
MIME-Version: 1.0
In-Reply-To: <1528402350.5265.21.camel@2b52.sc.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, Andy Lutomirski <luto@amacapital.net>
Cc: Florian Weimer <fweimer@redhat.com>, Dmitry Safonov <dsafonov@virtuozzo.com>, Cyrill Gorcunov <gorcunov@openvz.org>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On 06/07/2018 01:12 PM, Yu-cheng Yu wrote:
>>> +int cet_restore_signal(unsigned long ssp)
>>> +{
>>> +       if (!current->thread.cet.shstk_enabled)
>>> +               return 0;
>>> +       return cet_set_shstk_ptr(ssp);
>>> +}
>> This will blow up if the shadow stack enabled state changes in a
>> signal handler.  Maybe we don't care.
> Yes, the task will get a control protection fault.

Sounds like something to add to the very long list of things that are
unwise to do in a signal handler.  Great manpage fodder.
