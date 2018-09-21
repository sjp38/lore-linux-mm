Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 330E78E0002
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 13:26:35 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d13-v6so3714085pln.0
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 10:26:35 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id i5-v6si27014613pgo.197.2018.09.21.10.26.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 10:26:33 -0700 (PDT)
Message-ID: <c2d5d7944b7a34b67ddc0e5c1d3600e63c426236.camel@intel.com>
Subject: Re: [RFC PATCH v4 23/27] mm/map: Add Shadow stack pages to memory
 accounting
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Fri, 21 Sep 2018 10:21:50 -0700
In-Reply-To: <8c18fabf-170f-9010-3075-238e34c9f09b@infradead.org>
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
	 <20180921150351.20898-24-yu-cheng.yu@intel.com>
	 <8c18fabf-170f-9010-3075-238e34c9f09b@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Fri, 2018-09-21 at 09:55 -0700, Randy Dunlap wrote:
> On 9/21/18 8:03 AM, Yu-cheng Yu wrote:
> > Add shadow stack pages to memory accounting.
> > Also check if the system has enough memory before enabling CET.
> > 
> > Signed-off-by: Yu-cheng Yu <yu-cheng.yu.intel.com>
> 
> oops. typo above.
> 

I will fix it.  Thanks!
