Subject: Re: PATCH -ac -> -rmap 5/4
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <Pine.LNX.4.44L.0211131211040.3817-100000@imladris.surriel.com>
References: <Pine.LNX.4.44L.0211131211040.3817-100000@imladris.surriel.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 13 Nov 2002 14:51:23 +0000
Message-Id: <1037199083.11996.77.camel@irongate.swansea.linux.org.uk>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Arjan van de Ven <arjanv@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2002-11-13 at 14:12, Rik van Riel wrote:
> Hi,
> 
> this surprise patch (by arjan) adds a wmb() to the kswapd
> sleep path and is needed for some reason I've forgotten
> already

I'd like to know why. That looks fishy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
