Subject: Re: Fix sleep_on abuse in XFS, Was: Re: 2.6.2-rc2-mm1 (Breakage?)
From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <20040128133357.A28038@infradead.org>
References: <20040127233402.6f5d3497.akpm@osdl.org>
	 <200401281313.03790.ender@debian.org>
	 <200401281225.37234.s0348365@sms.ed.ac.uk>
	 <20040128133357.A28038@infradead.org>
Content-Type: text/plain
Message-Id: <1075300114.1633.156.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Date: Wed, 28 Jan 2004 14:28:34 +0000
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Alistair John Strachan <s0348365@sms.ed.ac.uk>, linux-kernel@vger.kernel.org, David =?ISO-8859-1?Q?Mart=EDnez?= Moreno <ender@debian.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2004-01-28 at 13:33 +0000, Christoph Hellwig wrote:
> +	complete(&pagebuf_daemon_done);
>  	return 0;

Use complete_and_exit() please. S'what it was invented for.

-- 
dwmw2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
