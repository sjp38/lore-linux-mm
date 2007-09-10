Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id l8ANLaOd000579
	for <linux-mm@kvack.org>; Tue, 11 Sep 2007 00:21:37 +0100
Received: from an-out-0708.google.com (andd23.prod.google.com [10.100.30.23])
	by zps18.corp.google.com with ESMTP id l8ANLXP3004755
	for <linux-mm@kvack.org>; Mon, 10 Sep 2007 16:21:33 -0700
Received: by an-out-0708.google.com with SMTP id d23so190703and
        for <linux-mm@kvack.org>; Mon, 10 Sep 2007 16:21:32 -0700 (PDT)
Message-ID: <6599ad830709101621r2f1763cfpa0924f884d0ee2c@mail.gmail.com>
Date: Mon, 10 Sep 2007 16:21:32 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC] [PATCH] memory controller statistics
In-Reply-To: <46E12020.1060203@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070907033942.4A6541BFA52@siro.lan>
	 <46E12020.1060203@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, svaidy@linux.vnet.ibm.com, containers@lists.osdl.org, minoura@valinux.co.jp, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 9/7/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
> Thanks for doing this. We are building containerstats for
> per container statistics. It would be really nice to provide
> the statistics using that interface. I am not opposed to
> memory.stat, but Paul Menage recommends that one file has
> just one meaningful value.

That's based on examples from other virtual filesystems such as sysfs.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
