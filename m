Date: Fri, 23 Jan 2004 10:43:00 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.2-rc1-mm2
Message-Id: <20040123104300.401bf385.akpm@osdl.org>
In-Reply-To: <200401231012.56686.edt@aei.ca>
References: <20040123013740.58a6c1f9.akpm@osdl.org>
	<200401231012.56686.edt@aei.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <edt@aei.ca>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ed Tomlinson <edt@aei.ca> wrote:
>
> Hi,
> 
> This fails to boot here.  Config is 2-rc1 updated with oldconfig.  It seems that it cannot 
> find root.

That's odd.

>  I did enable generic ide.  If required,  I'll enable a serial console and get a log 
> tonight.

Would be appreciated, thanks.  Or you could try reverting
suspicious-looking new patches which were added to mm2.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
