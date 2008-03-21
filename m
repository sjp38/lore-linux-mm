Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id m2LCDpk8002700
	for <linux-mm@kvack.org>; Fri, 21 Mar 2008 05:13:51 -0700
Received: from fg-out-1718.google.com (fgae12.prod.google.com [10.86.56.12])
	by zps18.corp.google.com with ESMTP id m2LCDewc026629
	for <linux-mm@kvack.org>; Fri, 21 Mar 2008 05:13:51 -0700
Received: by fg-out-1718.google.com with SMTP id e12so1141732fga.3
        for <linux-mm@kvack.org>; Fri, 21 Mar 2008 05:13:50 -0700 (PDT)
Message-ID: <d43160c70803210513q13a9341avaf952a6ce39b9f39@mail.gmail.com>
Date: Fri, 21 Mar 2008 08:13:50 -0400
From: "Ross Biro" <rossb@google.com>
Subject: Re: [RFC][PATCH 1/2]: MM: Make Page Tables Reloctable: Conditional TLB Flush
In-Reply-To: <20080321164450.4F8F.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080319141829.1F2E4DC98D@localhost>
	 <20080321164450.4F8F.E1E9C6FF@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 21, 2008 at 3:56 AM, Yasunori Goto <y-goto@jp.fujitsu.com> wrote:
>  Could you rebase them for newest kernel or -mm?
>  And please remove many of "#if 1" in the second patch.
>

Sorry, the #if 1's are debugging code.  I thought I had already gotten
them all.  I've just built the latest -mm.  I'll be porting the
patches over the next couple of days.

    Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
