Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 594649000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 06:06:07 -0400 (EDT)
Received: by fxh17 with SMTP id 17so9047715fxh.14
        for <linux-mm@kvack.org>; Tue, 27 Sep 2011 03:06:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4E7DECA0.5020707@parallels.com>
References: <1316393805-3005-1-git-send-email-glommer@parallels.com>
	<1316393805-3005-2-git-send-email-glommer@parallels.com>
	<4E794AA2.9080008@parallels.com>
	<CAKTCnzmkuL+9ftD5d0Z8b5w+DUSUoLiWqSX_TgGxtRxtoPsxpA@mail.gmail.com>
	<4E7DECA0.5020707@parallels.com>
Date: Tue, 27 Sep 2011 15:36:04 +0530
Message-ID: <CAKTCnz=DFUc=s9LzxPp-P2jOPXvNzWj8OswadCR09nVmM=ozxQ@mail.gmail.com>
Subject: Re: [PATCH v3 1/7] Basic kernel memory functionality for the Memory Controller
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, Ying Han <yinghan@google.com>

>> I know we have a lot of pending xxx_from_cont() and struct cgroup
>> *cont, can we move it to memcg notation to be more consistent with our
>> usage. There is a patch to convert old usage
>>
>
> Hello Balbir, I missed this comment. What exactly do you propose in this
> patch, since I have to assume that the patch you talk about is not applied?
> Is it just a change to the parameter name that you propose?
>

Yes, it is a patch posted on linux-mm by raghavendra

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
