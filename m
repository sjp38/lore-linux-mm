Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0A9516B025F
	for <linux-mm@kvack.org>; Sat,  2 Sep 2017 13:35:35 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 4so8495786pgi.5
        for <linux-mm@kvack.org>; Sat, 02 Sep 2017 10:35:35 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id y25si2198023pgc.536.2017.09.02.10.35.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Sep 2017 10:35:32 -0700 (PDT)
Message-ID: <1504373731.19040.4.camel@ranerica-desktop>
Subject: Re: [PATCH v8 02/28] x86/boot: Relocate definition of the initial
 state of CR0
From: Ricardo Neri <ricardo.neri-calderon@linux.intel.com>
Date: Sat, 02 Sep 2017 10:35:31 -0700
In-Reply-To: <20170831095113.huidayjchfsdabjz@pd.tnic>
References: <20170819002809.111312-1-ricardo.neri-calderon@linux.intel.com>
	 <20170819002809.111312-3-ricardo.neri-calderon@linux.intel.com>
	 <20170825174133.r5xhcv5utfipsujo@pd.tnic>
	 <1504152258.51857.8.camel@ranerica-desktop>
	 <20170831095113.huidayjchfsdabjz@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>
Cc: Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Brian Gerst <brgerst@gmail.com>, Chris Metcalf <cmetcalf@mellanox.com>, Dave Hansen <dave.hansen@linux.intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Masami Hiramatsu <mhiramat@kernel.org>, Huang Rui <ray.huang@amd.com>, Jiri Slaby <jslaby@suse.cz>, Jonathan Corbet <corbet@lwn.net>, "Michael S. Tsirkin" <mst@redhat.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Vlastimil Babka <vbabka@suse.cz>, Chen Yucong <slaoub@gmail.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Shuah Khan <shuah@kernel.org>, linux-kernel@vger.kernel.org, x86@kernel.org, Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Thu, 2017-08-31 at 11:51 +0200, Borislav Petkov wrote:
> On Wed, Aug 30, 2017 at 09:04:18PM -0700, Ricardo Neri wrote:
> > Thank you! Is it necessary for me to submit a v9 with these updates?
> > Perhaps I can make these updates in branch for the maintainers to pull
> > when/if this series is ack'ed.
> 
> Don't do anything and let me go through the rest of them first. It is
> too late for this merge window anyway so we can take our time. Once you
> receive full feedback from me (and hopefully others) you can send what
> looks like to be a final v9 with all feedback incorporated. :-)

Sure, I will wait until you (and hopefully others) are done reviewing.

Thanks and BR,
Ricardo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
