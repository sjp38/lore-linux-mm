Message-ID: <3B9A73D5.9020607@interactivesi.com>
Date: Sat, 08 Sep 2001 14:39:01 -0500
From: Timur Tabi <ttabi@interactivesi.com>
MIME-Version: 1.0
Subject: Re: kernel hangs in 118th call to vmalloc
References: <3B8FDA36.5010206@interactivesi.com> <m1ae05h6we.fsf@frodo.biederman.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Eric W. Biederman wrote:

> What is wrong with using SPD to detect interesting properties of
> memory chips?  That should be safer and usually easier then what you
> are trying now. 

Our hardware does not interface with SPD.  So I can't use SPD to query the 
properties.  Besides, it wouldn't change anything if I did.  I still need to 
clear out RAM.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
