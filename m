From: David Mosberger <davidm@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <15690.10852.935317.603783@napali.hpl.hp.com>
Date: Thu, 1 Aug 2002 23:44:52 -0700
Subject: Re: large page patch 
In-Reply-To: <868823061.1028244804@[10.10.2.3]>
References: <15690.9727.831144.67179@napali.hpl.hp.com>
	<868823061.1028244804@[10.10.2.3]>
Reply-To: davidm@hpl.hp.com
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: davidm@hpl.hp.com, "David S. Miller" <davem@redhat.com>, riel@conectiva.com.br, akpm@zip.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rohit.seth@intel.com, sunil.saxena@intel.com, asit.k.mallick@intel.com
List-ID: <linux-mm.kvack.org>

>>>>> On Thu, 01 Aug 2002 23:33:26 -0700, "Martin J. Bligh" <Martin.Bligh@us.ibm.com> said:

  DaveM> In my opinion the proposed large-page patch addresses a
  DaveM> relatively pressing need for databases (primarily).
  >>
  DaveM> Databases want large pages with IPC_SHM, how can this special
  DaveM> syscal hack address that?

  >>  I believe the interface is OK in that regard.  AFAIK, Oracle is
  >> happy with it.

  Martin> Is Oracle now the world's only database? I think not.

I didn't say such a thing.  I just don't know what other db vendors/authors
think of the proposed interface.  I'm sure their feedback would be welcome.

	--david
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
