Subject: Re: [Lhms-devel] new memory hotremoval patch
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20040701055836.A688F70A92@sv1.valinux.co.jp>
References: <20040630111719.EBACF70A92@sv1.valinux.co.jp>
	 <1088640671.5265.1017.camel@nighthawk>
	 <20040701030543.8CE8F70A92@sv1.valinux.co.jp>
	 <1088659723.10720.3.camel@nighthawk>
	 <20040701055836.A688F70A92@sv1.valinux.co.jp>
Content-Type: text/plain
Message-Id: <1088662503.10720.6.camel@nighthawk>
Mime-Version: 1.0
Date: Wed, 30 Jun 2004 23:15:03 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2004-06-30 at 22:58, IWAMOTO Toshihiro wrote:
> Such code only appears only in try_to_unuse and do_swap_page.  These
> functions aren't for page caches.
> 
> I'm confused.  Weren't you talking about page cache code?

Ahh.  Gotcha.  MI saw some of the BUG_ON()s and some of the swap code
and misinterpreted where the flag was being used.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
