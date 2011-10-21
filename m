Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E6B926B002D
	for <linux-mm@kvack.org>; Fri, 21 Oct 2011 12:04:08 -0400 (EDT)
Received: by gyf3 with SMTP id 3so5285271gyf.14
        for <linux-mm@kvack.org>; Fri, 21 Oct 2011 09:04:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20111020105950.fd04f58f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20111020013305.GD21703@tiehlicka.suse.cz>
	<20111020105950.fd04f58f.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 21 Oct 2011 21:34:06 +0530
Message-ID: <CAKTCnz=iZp37sBfY++HUU0oscskFF_UWYeFYtAujtQh4_B=vHQ@mail.gmail.com>
Subject: Re: [RFD] Isolated memory cgroups again
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, Kir Kolyshkin <kir@parallels.com>, Pavel Emelianov <xemul@parallels.com>, GregThelen <gthelen@google.com>, "pjt@google.com" <pjt@google.com>, Tim Hockin <thockin@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Paul Menage <paul@paulmenage.org>, James Bottomley <James.Bottomley@hansenpartnership.com>

On Thu, Oct 20, 2011 at 7:29 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 19 Oct 2011 18:33:09 -0700
> Michal Hocko <mhocko@suse.cz> wrote:
>
>> Hi all,
>> this is a request for discussion (I hope we can touch this during memcg
>> meeting during the upcoming KS). I have brought this up earlier this
>> year before LSF (http://thread.gmane.org/gmane.linux.kernel.mm/60464).
>> The patch got much smaller since then due to excellent Johannes' memcg
>> naturalization work (http://thread.gmane.org/gmane.linux.kernel.mm/68724)
>> which this is based on.
>

Hi, Michal

I'd like to understand, what the isolation is for?

1. Is it an alternative to memory guarantees?
2. How is this different from doing cpusets (fake NUMA) and isolating them?

Just trying to catch up,
Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
