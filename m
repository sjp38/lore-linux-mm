Date: Fri, 02 Aug 2002 02:06:53 -0700 (PDT)
Message-Id: <20020802.020653.105601161.davem@redhat.com>
Subject: Re: large page patch
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <200208020205.47308.ryan@completely.kicks-ass.org>
References: <15690.9727.831144.67179@napali.hpl.hp.com>
	<20020802.012040.105531210.davem@redhat.com>
	<200208020205.47308.ryan@completely.kicks-ass.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ryan@completely.kicks-ass.org
Cc: davidm@hpl.hp.com, davidm@napali.hpl.hp.com, gh@us.ibm.com, riel@conectiva.com.br, akpm@zip.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rohit.seth@intel.com, sunil.saxena@intel.com, asit.k.mallick@intel.com
List-ID: <linux-mm.kvack.org>

   
   What about applications that want fine-grained page aging? 4MB is a
   tad on the course side for most desktop applications.

Once vmscan sees the page and tries to liberate it, then it
will be unlarge'd and thus you'll get fine-grained page aging.

That's the beauty of my implementation suggestion.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
