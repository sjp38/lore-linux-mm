Date: Fri, 7 Jan 2005 19:12:34 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC] per thread page reservation patch
Message-ID: <20050107191234.GA14108@infradead.org>
References: <20050103011113.6f6c8f44.akpm@osdl.org> <20050103114854.GA18408@infradead.org> <41DC2386.9010701@namesys.com> <1105019521.7074.79.camel@tribesman.namesys.com> <20050107144644.GA9606@infradead.org> <1105118217.3616.171.camel@tribesman.namesys.com> <20050107190545.GA13898@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050107190545.GA13898@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Vladimir Saveliev <vs@namesys.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> Now the big question is, what's synchronizing access to
> current->private_pages?

Umm, it's obviously correct as we're thread-local.  Objection taken back :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
