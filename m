Received: from www21.ureach.com (www21.ureach.com [172.16.2.49])
	by ureach.com (8.9.1/8.8.5) with ESMTP id IAA09201
	for <linux-mm@kvack.org>; Fri, 6 Sep 2002 08:20:29 -0400
Date: Fri, 6 Sep 2002 08:20:29 -0400
Message-Id: <200209061220.IAA02560@www21.ureach.com>
From: Kapish K <kapish@ureach.com>
Reply-to: <kapish@ureach.com>
Subject: address_space pointers in inode structure
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,
  I have a query related to address_space
pointers in the inode structure; there are
two address_space pointers ( i_mapping and
i_data ); most of the code, seems to use the
i_mapping pointer to get to the pages of the
filesystem object pointed to by the inode
and seems ok. However, i_data also seems to
be used for truncate_inode_pages.
What exactly is the logical difference
between the two and when does one need to
maek the distinction between the two pointers?
Any pointers or information would be most
helpful
Thanks

________________________________________________
Get your own "800" number
Voicemail, fax, email, and a lot more
http://www.ureach.com/reg/tag
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
