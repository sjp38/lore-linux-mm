Subject: Re: 2.5.68-mm2
From: Robert Love <rml@tech9.net>
In-Reply-To: <20030425112042.37493d02.rddunlap@osdl.org>
References: <20030424163334.A12180@redhat.com>
	 <Pine.LNX.3.96.1030425135538.16623C-100000@gatekeeper.tmr.com>
	 <20030425112042.37493d02.rddunlap@osdl.org>
Content-Type: text/plain
Message-Id: <1051295252.9767.143.camel@localhost>
Mime-Version: 1.0
Date: 25 Apr 2003 14:27:32 -0400
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Randy.Dunlap" <rddunlap@osdl.org>
Cc: Bill Davidsen <davidsen@tmr.com>, bcrl@redhat.com, akpm@digeo.com, mbligh@aracnet.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2003-04-25 at 14:20, Randy.Dunlap wrote:
>  
> | The point is that even if bash is fixed it's desirable to address the
> | issue in the kernel, other applications may well misbehave as well.
> 
> So when would this ever end?

Exactly what I was thinking.

The kernel cannot be expected to cater to applications or make
concessions (read: hacks) for certain behavior.  If we offer a cleaner,
improved interface which offers the performance improvement, we are
done.  Applications need to start using it.

Of course, I am not arguing against optimizing the old interfaces or
anything of that nature.  I just believe we should not introduce hacks
for application behavior.  It is their job to do the right thing.

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
