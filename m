Date: Thu, 27 Jan 2005 11:37:40 +0100
From: Adrian Bunk <bunk@stusta.de>
Subject: Re: reiser4 core patches: [Was: [RFC] per thread page reservation patch]
Message-ID: <20050127103740.GD28047@stusta.de>
References: <20050103011113.6f6c8f44.akpm@osdl.org> <20050103114854.GA18408@infradead.org> <41DC2386.9010701@namesys.com> <1105019521.7074.79.camel@tribesman.namesys.com> <20050107144644.GA9606@infradead.org> <1105118217.3616.171.camel@tribesman.namesys.com> <41DEDF87.8080809@grupopie.com> <m1llb5q7qs.fsf@clusterfs.com> <20050107132459.033adc9f.akpm@osdl.org> <1106671038.4466.81.camel@tribesman.namesys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1106671038.4466.81.camel@tribesman.namesys.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vladimir Saveliev <vs@namesys.com>
Cc: Andrew Morton <akpm@osdl.org>, Christoph Hellwig <hch@infradead.org>, Nikita Danilov <nikita@clusterfs.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Vladimir,

a general request:

If you add new EXPORT_SYMBOL's, I'd strongly prefer them being 
EXPORT_SYMBOL_GPL's unless there's a very good reason for an 
EXPORT_SYMBOL.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
