Date: Wed, 19 Sep 2001 15:21:18 -0700 (PDT)
Message-Id: <20010919.152118.78708122.davem@redhat.com>
Subject: Re: broken VM in 2.4.10-pre9
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <878A2048A35CD141AD5FC92C6B776E4907B7A5@xchgind02.nsisw.com>
References: <878A2048A35CD141AD5FC92C6B776E4907B7A5@xchgind02.nsisw.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: rfuller@nsisoftware.com
Cc: ebiederm@xmission.com, alan@lxorguk.ukuu.org.uk, phillips@bonn-fries.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   I suppose I confused the issue when I offered a supporting argument for
   reverse mappings.  It's not reverse mappings for anonymous pages I'm
   advocating, but reverse mappings for mapped file data.

We already have reverse mappings for files, via the VMA chain off the
inode.

Later,
David S. Miller
davem@redhat.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
