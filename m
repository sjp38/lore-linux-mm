Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id E6D656B13F0
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 22:35:46 -0500 (EST)
Received: by lamf4 with SMTP id f4so4989754lam.14
        for <linux-mm@kvack.org>; Mon, 06 Feb 2012 19:35:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAG4AFWaXVEHP+YikRSyt8ky9XsiBnwQ3O94Bgc7-b7nYL_2PZQ@mail.gmail.com>
References: <CAG4AFWaXVEHP+YikRSyt8ky9XsiBnwQ3O94Bgc7-b7nYL_2PZQ@mail.gmail.com>
Date: Mon, 6 Feb 2012 21:35:44 -0600
Message-ID: <CANAOKxs8j2T2b0tKssFX9NeC1wyMqjLMQmgmRwMs9qvokYcW2w@mail.gmail.com>
Subject: Re: Strange finding about kernel samepage merging
From: Michael Roth <mdroth@linux.vnet.ibm.com>
Content-Type: multipart/alternative; boundary=f46d043bd6fe5d249c04b857797a
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jidong Xiao <jidong.xiao@gmail.com>
Cc: linux-mm@kvack.org, virtualization@lists.linux-foundation.org

--f46d043bd6fe5d249c04b857797a
Content-Type: text/plain; charset=ISO-8859-1

My guess is you end up with 2 copies of each page on the guest: the copy in
the guest's page cache, and the copy in the buffer you allocated. From the
perspective of the host this all looks like anonymous memory, so ksm merges
the pages.

--f46d043bd6fe5d249c04b857797a
Content-Type: text/html; charset=ISO-8859-1

My guess is you end up with 2 copies of each page on the guest: the copy
 in the guest&#39;s page cache, and the copy in the buffer you allocated. From the 
perspective of the host this all looks like anonymous memory, so ksm 
merges the pages.<br>

--f46d043bd6fe5d249c04b857797a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
