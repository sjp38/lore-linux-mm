Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id EE96B6B0007
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 10:26:00 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id y7-v6so5362952plt.17
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 07:26:00 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r125-v6si7876993pfc.202.2018.06.15.07.25.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jun 2018 07:25:59 -0700 (PDT)
Message-ID: <1529072566.17958.4.camel@2b52.sc.intel.com>
Subject: Re: [PATCH 5/5] Documentation/x86: Add CET description
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Fri, 15 Jun 2018 07:22:46 -0700
In-Reply-To: <20180615111424.GA4473@amd>
References: <20180607143544.3477-1-yu-cheng.yu@intel.com>
	 <20180607143544.3477-6-yu-cheng.yu@intel.com> <20180615111424.GA4473@amd>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter
 Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>

On Fri, 2018-06-15 at 13:14 +0200, Pavel Machek wrote:
> On Thu 2018-06-07 07:35:44, Yu-cheng Yu wrote:
> > Explain how CET works and the noshstk/noibt kernel parameters.
> > 
> > Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> > ---
> >  Documentation/admin-guide/kernel-parameters.txt |   6 +
> >  Documentation/x86/intel_cet.txt                 | 161 ++++++++++++++++++++++++
> 
> Should new files be .rst formatted or something like that?
> 									Pavel

I will fix kernel-parameters.rst.  But currently there is no .rst in
Documentation/x86?

Yu-cheng
