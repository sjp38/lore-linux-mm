Date: Thu, 01 Aug 2002 18:50:29 -0700 (PDT)
Message-Id: <20020801.185029.79271639.davem@redhat.com>
Subject: Re: large page patch
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <Pine.LNX.4.44L.0208012246390.23404-100000@imladris.surriel.com>
References: <20020801.174301.123634127.davem@redhat.com>
	<Pine.LNX.4.44L.0208012246390.23404-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com.br
Cc: akpm@zip.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rohit.seth@intel.com, sunil.saxena@intel.com, asit.k.mallick@intel.com, gh@us.ibm.com
List-ID: <linux-mm.kvack.org>

   
   IMHO we shouldn't blindly decide for (or against!) this patch
   but also carefully look at the large page patch from RHAS (which
   got added to -aa recently) and the large page patch which IBM
   is working on.

And the one from Naohiko Shimizu which is my personal favorite
because sparc64 support is there :)

http://shimizu-lab.dt.u-tokai.ac.jp/lsp.html
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
