Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id EFE4E6B005C
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 12:12:44 -0500 (EST)
Message-ID: <4EDF9E8C.6010801@jp.fujitsu.com>
Date: Wed, 07 Dec 2011 12:12:44 -0500
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: mark some messages as INFO
References: <1323277360-3155-1-git-send-email-teg@jklm.no>
In-Reply-To: <1323277360-3155-1-git-send-email-teg@jklm.no>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: teg@jklm.no
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/7/2011 12:02 PM, Tom Gundersen wrote:
> This reduces the noise in
> 
> $ dmesg --kernel --level=err,warn
> 
> Signed-off-by: Tom Gundersen <teg@jklm.no>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
