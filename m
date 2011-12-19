Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 5F6FF6B004D
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 16:15:22 -0500 (EST)
Received: by ghrr18 with SMTP id r18so4270465ghr.14
        for <linux-mm@kvack.org>; Mon, 19 Dec 2011 13:15:21 -0800 (PST)
Message-ID: <4EEFA96C.1080106@gmail.com>
Date: Mon, 19 Dec 2011 16:15:24 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH][RESEND] mm: Fix off-by-one bug in print_nodes_state
References: <1324209529-15892-1-git-send-email-ozaki.ryota@gmail.com> <alpine.DEB.2.00.1112181439500.1364@chino.kir.corp.google.com> <4EEE6DC0.2030007@gmail.com> <alpine.DEB.2.00.1112191252130.28684@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1112191252130.28684@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Ryota Ozaki <ozaki.ryota@gmail.com>, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>, linux-mm@kvack.org, stable@kernel.org

(12/19/11 3:53 PM), David Rientjes wrote:
> On Sun, 18 Dec 2011, KOSAKI Motohiro wrote:
>
>> Usually, /sys files don't output trailing 'AJPY0'. And, 'AJPY0' is not regular
>> io friendly. So I can imagine some careless programmer think it is garbage. Is
>> there any benefit to show trailing 'AJPY0'?
>>
>
> Nope, it could be removed since the buffer is allocated with
> get_zeroed_page().

ok, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
