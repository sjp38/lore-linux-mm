Message-ID: <3ABA11F3.60004@missioncriticallinux.com>
Date: Thu, 22 Mar 2001 09:53:39 -0500
From: "Patrick O'Rourke" <orourke@missioncriticallinux.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Prevent OOM from killing init
References: <Pine.LNX.4.21.0103212047590.19934-100000@imladris.rielhome.conectiva>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:


> One question ... has the OOM killer ever selected init on
> anybody's system ?

Yes, which is why I created the patch.

-- 
Patrick O'Rourke
978.606.0236
orourke@missioncriticallinux.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
