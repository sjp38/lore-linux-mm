Date: Wed, 07 May 2003 06:40:10 -0700 (PDT)
Message-Id: <20030507.064010.42794250.davem@redhat.com>
Subject: Re: 2.5.69-mm2 Kernel panic, possibly network related
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030507144100.GD8978@holomorphy.com>
References: <3EB8E4CC.8010409@aitel.hist.no>
	<20030507.025626.10317747.davem@redhat.com>
	<20030507144100.GD8978@holomorphy.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: wli@holomorphy.com
Cc: helgehaf@aitel.hist.no, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@digeo.com
List-ID: <linux-mm.kvack.org>

   
   In another thread, you mentioned that a certain netfilter cset had
   issues; I think it might be good to add that as a second possible
   cause.

Good point, Helge what netfilter stuff do you have in use?
Are you doing NAT?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
