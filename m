Date: Mon, 14 Oct 2002 06:18:14 -0700 (PDT)
Message-Id: <20021014.061814.06551321.davem@redhat.com>
Subject: Re: [patch, feature] nonlinear mappings, prefaulting support,
 2.5.42-F8
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <Pine.LNX.4.44.0210141525250.21947-100000@localhost.localdomain>
References: <20021014.054500.89132620.davem@redhat.com>
	<Pine.LNX.4.44.0210141525250.21947-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu
Cc: torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   
   Where to draw the line between a loop of INVLPG and a CR3 flush on
   x86 is up in the air - i'd say it's at roughly 8 pages currently

I'd say it's highly x86 revision dependant and that it
can be easily calibrated at boot time :-)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
