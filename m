Date: Fri, 7 Jan 2005 22:24:38 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] per thread page reservation patch
Message-ID: <20050107212438.GB13026@wotan.suse.de>
References: <20050103011113.6f6c8f44.akpm@osdl.org> <20050103114854.GA18408@infradead.org> <41DC2386.9010701@namesys.com> <1105019521.7074.79.camel@tribesman.namesys.com> <20050107144644.GA9606@infradead.org> <1105118217.3616.171.camel@tribesman.namesys.com> <41DEDF87.8080809@grupopie.com> <m1llb5q7qs.fsf@clusterfs.com> <20050107132459.033adc9f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050107132459.033adc9f.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nikita Danilov <nikita@clusterfs.com>, pmarques@grupopie.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hch@infradead.org
List-ID: <linux-mm.kvack.org>

> And the whole idea is pretty flaky really - how can one precalculate how
> much memory an arbitrary md-on-dm-on-loop-on-md-on-NBD stack will want to
> use?  It really would be better if we could drop the whole patch and make
> reiser4 behave more sanely when its writepage is called with for_reclaim=1.

Or just preallocate into a private array. 

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
