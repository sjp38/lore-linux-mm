Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 832696B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 18:32:16 -0400 (EDT)
Received: by werj55 with SMTP id j55so99296wer.14
        for <linux-mm@kvack.org>; Thu, 26 Apr 2012 15:32:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F99CC17.4080006@parallels.com>
References: <1335475463-25167-1-git-send-email-glommer@parallels.com>
	<1335475463-25167-3-git-send-email-glommer@parallels.com>
	<20120426213916.GD27486@google.com>
	<4F99C50D.6070503@parallels.com>
	<20120426221324.GE27486@google.com>
	<4F99C980.3030801@parallels.com>
	<CAOS58YOKUq7GTTZRcw19dth+HgThoNTEcqBKeNO0ftB4rFJ97A@mail.gmail.com>
	<4F99CC17.4080006@parallels.com>
Date: Thu, 26 Apr 2012 15:32:14 -0700
Message-ID: <CAOS58YPKtZ-oLOtaNqgbxB4Nf0Vc=eL+FjgfMj4a9T0yjn57Sg@mail.gmail.com>
Subject: Re: [PATCH v3 2/2] decrement static keys on real destroy time
From: Tejun Heo <tj@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, netdev@vger.kernel.org, Li Zefan <lizefan@huawei.com>, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, devel@openvz.org

On Thu, Apr 26, 2012 at 3:28 PM, Glauber Costa <glommer@parallels.com> wrote:
> We need a broader audience for this, but if I understand the interface
> right, those functions should not be called in fast paths at all (contrary
> to the static_branch tests)
>
> The static_branch tests can be called from irq context, so we can't just get
> rid of the atomic op and use the mutex everywhere, we'd have
> to live with both.
>
> I will repost this series, with some more people in the CC list.

Great, thanks!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
