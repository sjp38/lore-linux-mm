From: "Jalajadevi Ganapathy" <JGanapathy@storage.com>
Subject: kfree_skb!!
Message-ID: <OFA04D8203.E9EEE0AC-ON85256A6A.0050EB63@storage.com>
Date: Wed, 13 Jun 2001 10:45:58 -0400
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Hi, When I do any any operation on my driver, I get a warning as

Warning: kfree_skb on hard IRQ c888bf85


Could anyone plz tell me wat does it mean? Is that I am freeing a pointer
which is already freed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
