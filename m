Date: Wed, 29 Jan 2003 01:35:30 -0800 (PST)
Message-Id: <20030129.013530.98324132.davem@redhat.com>
Subject: Re: Linus rollup
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030129013354.03f5ee33.akpm@digeo.com>
References: <20030128220729.1f61edfe.akpm@digeo.com>
	<20030129013354.03f5ee33.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@digeo.com
Cc: rmk@arm.linux.org.uk, ak@muc.de, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   
   Forgot to mention:
   
I wish there was some way people could easily add an
#error to the build so that arch's know which syscalls
need to be added next time someone tries to run make
for that platform.

Nothing comes immediately to mind as an idea however.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
