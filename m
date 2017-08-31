Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9A6726B0292
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 05:51:35 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p42so244439wrb.1
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 02:51:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 64si3455361wrq.378.2017.08.31.02.51.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 Aug 2017 02:51:33 -0700 (PDT)
Date: Thu, 31 Aug 2017 11:51:14 +0200
From: Borislav Petkov <bp@suse.de>
Subject: Re: [PATCH v8 02/28] x86/boot: Relocate definition of the initial
 state of CR0
Message-ID: <20170831095113.huidayjchfsdabjz@pd.tnic>
References: <20170819002809.111312-1-ricardo.neri-calderon@linux.intel.com>
 <20170819002809.111312-3-ricardo.neri-calderon@linux.intel.com>
 <20170825174133.r5xhcv5utfipsujo@pd.tnic>
 <1504152258.51857.8.camel@ranerica-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1504152258.51857.8.camel@ranerica-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ricardo Neri <ricardo.neri-calderon@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Brian Gerst <brgerst@gmail.com>, Chris Metcalf <cmetcalf@mellanox.com>, Dave Hansen <dave.hansen@linux.intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Masami Hiramatsu <mhiramat@kernel.org>, Huang Rui <ray.huang@amd.com>, Jiri Slaby <jslaby@suse.cz>, Jonathan Corbet <corbet@lwn.net>, "Michael S. Tsirkin" <mst@redhat.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Vlastimil Babka <vbabka@suse.cz>, Chen Yucong <slaoub@gmail.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Shuah Khan <shuah@kernel.org>, linux-kernel@vger.kernel.org, x86@kernel.org, Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Wed, Aug 30, 2017 at 09:04:18PM -0700, Ricardo Neri wrote:
> Thank you! Is it necessary for me to submit a v9 with these updates?
> Perhaps I can make these updates in branch for the maintainers to pull
> when/if this series is ack'ed.

Don't do anything and let me go through the rest of them first. It is
too late for this merge window anyway so we can take our time. Once you
receive full feedback from me (and hopefully others) you can send what
looks like to be a final v9 with all feedback incorporated. :-)

Thx.

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
