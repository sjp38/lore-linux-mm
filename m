Date: Thu, 01 Aug 2002 22:20:53 -0700 (PDT)
Message-Id: <20020801.222053.20302294.davem@redhat.com>
Subject: Re: large page patch 
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <15690.6005.624237.902152@napali.hpl.hp.com>
References: <Pine.LNX.4.44L.0208012246390.23404-100000@imladris.surriel.com>
	<E17aSCT-0008I0-00@w-gerrit2>
	<15690.6005.624237.902152@napali.hpl.hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: davidm@hpl.hp.com, davidm@napali.hpl.hp.com
Cc: gh@us.ibm.com, riel@conectiva.com.br, akpm@zip.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rohit.seth@intel.com, sunil.saxena@intel.com, asit.k.mallick@intel.com
List-ID: <linux-mm.kvack.org>

   
   In my opinion the proposed large-page patch addresses a relatively
   pressing need for databases (primarily).

Databases want large pages with IPC_SHM, how can this special
syscal hack address that?

It's great for experimentation, but give up syscall slots for
this?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
