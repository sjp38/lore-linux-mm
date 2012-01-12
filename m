Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 5A1416B004D
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 04:07:36 -0500 (EST)
Message-ID: <4F0EA367.8060105@cn.fujitsu.com>
Date: Thu, 12 Jan 2012 17:09:59 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Don't warn if memdup_user fails
References: <1326300636-29233-1-git-send-email-levinsasha928@gmail.com>	<alpine.DEB.2.00.1201111346180.21755@chino.kir.corp.google.com>	<alpine.LFD.2.02.1201120842140.2054@tux.localdomain> <CAOJsxLGTO8=w8nYADY9hVBs_63UGR-jfrPOYsgexDUo-pPFjDQ@mail.gmail.com>
In-Reply-To: <CAOJsxLGTO8=w8nYADY9hVBs_63UGR-jfrPOYsgexDUo-pPFjDQ@mail.gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Sasha Levin <levinsasha928@gmail.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Pekka Enberg wrote:
> On Thu, Jan 12, 2012 at 8:43 AM, Pekka Enberg <penberg@kernel.org> wrote:
>> Sasha, I suppose strndup_user() has the same kind of issue?
> 
> Oh, it uses memdup_user() internally. Sorry for the noise.
> 

Before memdup_user() was introduced, strndup_user() called kmalloc()
directly, without specifying __GFP_NOWARN.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
