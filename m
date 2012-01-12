Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id C08EC6B0069
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 01:44:52 -0500 (EST)
Received: by obbuo9 with SMTP id uo9so380462obb.14
        for <linux-mm@kvack.org>; Wed, 11 Jan 2012 22:44:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LFD.2.02.1201120842140.2054@tux.localdomain>
References: <1326300636-29233-1-git-send-email-levinsasha928@gmail.com>
	<alpine.DEB.2.00.1201111346180.21755@chino.kir.corp.google.com>
	<alpine.LFD.2.02.1201120842140.2054@tux.localdomain>
Date: Thu, 12 Jan 2012 08:44:51 +0200
Message-ID: <CAOJsxLGTO8=w8nYADY9hVBs_63UGR-jfrPOYsgexDUo-pPFjDQ@mail.gmail.com>
Subject: Re: [PATCH] mm: Don't warn if memdup_user fails
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, lizf@cn.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jan 12, 2012 at 8:43 AM, Pekka Enberg <penberg@kernel.org> wrote:
> Sasha, I suppose strndup_user() has the same kind of issue?

Oh, it uses memdup_user() internally. Sorry for the noise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
