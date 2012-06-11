Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 8DA0C6B0062
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 17:19:44 -0400 (EDT)
Received: by dakp5 with SMTP id p5so7299660dak.14
        for <linux-mm@kvack.org>; Mon, 11 Jun 2012 14:19:43 -0700 (PDT)
Message-ID: <4FD660EC.2010608@gmail.com>
Date: Mon, 11 Jun 2012 17:19:40 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix protection column misplacing in /proc/zoneinfo
References: <1339422650-9798-1-git-send-email-kosaki.motohiro@gmail.com> <alpine.DEB.2.00.1206110856180.31180@router.home> <4FD60127.1000805@jp.fujitsu.com> <alpine.DEB.2.00.1206111336370.4552@chino.kir.corp.google.com> <CAHGf_=rbss0RsoFn7NZ7oFCpCZuEYkPDXaHSW4KHg=Vu8703xA@mail.gmail.com> <alpine.DEB.2.00.1206111602540.9391@router.home>
In-Reply-To: <alpine.DEB.2.00.1206111602540.9391@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kosaki.motohiro@gmail.com

(6/11/12 5:04 PM), Christoph Lameter wrote:
> On Mon, 11 Jun 2012, KOSAKI Motohiro wrote:
>
>> Several years, some one added ZVC stat. therefore, hardcoded line
>
> You are talking to the "some one".... The aim at that point was not the
> beauty of the output but the scaling of the counter operations. There was
> no intention in placing things a certain way. I'd be fine with changes as
> long as we are sure that they do not break anything.

Maybe my english was poor. I didn't talk about your change at last mail. I
talked about some new counters like nr_anon_transparent_hugepages. Hardcoded
linenuber assumption was break multiple times already. therefore, I don't
think line number change causes application breakage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
