Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 59DE76B005C
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 15:53:18 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so5885263vbb.14
        for <linux-mm@kvack.org>; Mon, 19 Dec 2011 12:53:17 -0800 (PST)
Date: Mon, 19 Dec 2011 12:53:13 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH][RESEND] mm: Fix off-by-one bug in print_nodes_state
In-Reply-To: <4EEE6DC0.2030007@gmail.com>
Message-ID: <alpine.DEB.2.00.1112191252130.28684@chino.kir.corp.google.com>
References: <1324209529-15892-1-git-send-email-ozaki.ryota@gmail.com> <alpine.DEB.2.00.1112181439500.1364@chino.kir.corp.google.com> <4EEE6DC0.2030007@gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397155492-495150536-1324327973=:28684"
Content-ID: <alpine.DEB.2.00.1112191253010.28684@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Ryota Ozaki <ozaki.ryota@gmail.com>, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>, linux-mm@kvack.org, stable@kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397155492-495150536-1324327973=:28684
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.1112191253011.28684@chino.kir.corp.google.com>

On Sun, 18 Dec 2011, KOSAKI Motohiro wrote:

> Usually, /sys files don't output trailing 'AJPY0'. And, 'AJPY0' is not regular
> io friendly. So I can imagine some careless programmer think it is garbage. Is
> there any benefit to show trailing 'AJPY0'?
> 

Nope, it could be removed since the buffer is allocated with 
get_zeroed_page().
--397155492-495150536-1324327973=:28684--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
