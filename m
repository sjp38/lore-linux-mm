Date: Mon, 13 Nov 2000 10:16:23 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: reliability of linux-vm subsystem (fwd)
Message-ID: <Pine.LNX.3.96.1001113100358.7862B-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Please be sure to attribute properly when replying to this =)

>From erik@arthur.ubicom.tudelft.nl Mon Nov 13 08:07:24 2000
Received: from mailhst2.its.tudelft.nl ([130.161.34.250]:36616 "EHLO
        mailhst2.its.tudelft.nl") by kanga.kvack.org with ESMTP
	id <S131165AbQKMNHT>; Mon, 13 Nov 2000 08:07:19 -0500
Received: from arthur.ubicom.tudelft.nl (erik.et.tudelft.nl [130.161.48.56])
	by mailhst2.its.tudelft.nl (8.9.3/8.9.3) with ESMTP id OAA13625;
	Mon, 13 Nov 2000 14:08:29 +0100 (MET)
Received: (from erik@localhost)
	by arthur.ubicom.tudelft.nl (8.9.3/8.9.3/SuSE Linux 8.9.3-0.1) id OAA11830;
	Mon, 13 Nov 2000 14:06:41 +0100
Date:   Mon, 13 Nov 2000 14:06:41 +0100
From:   Erik Mouw <J.A.K.Mouw@ITS.TUDelft.NL>
To:     aprasad@in.ibm.com
Cc:     linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: reliability of linux-vm subsystem
Message-ID: <20001113140641.A11229@arthur.ubicom.tudelft.nl>
References: <CA256996.004352F8.00@d73mta05.au.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
X-Mailer: Mutt 1.0.1i
In-Reply-To: <CA256996.004352F8.00@d73mta05.au.ibm.com>; from aprasad@in.ibm.com on Mon, Nov 13, 2000 at 05:29:48PM +0530
Organization: Eric Conspiracy Secret Labs
X-Eric-Conspiracy: There is no conspiracy!
Return-Path: <erik@arthur.ubicom.tudelft.nl>
X-Orcpt: rfc822;linux-mm@kvack.org

On Mon, Nov 13, 2000 at 05:29:48PM +0530, aprasad@in.ibm.com wrote:
> When i run following code many times.
> System becomes useless till all of the instance of this programming are
> killed by vmm.

Good, so the OOM killer works.

> Till that time linux doesn't accept any command though it switches from one
> VT to another but its useless.

VT swithing is done by the kernel itself, not by a process.

> The above programme is run as normal user previleges.
> Theoretically load should increase but system should services other users
> too.

No. The system would *like* to service other processes, but it *can't*
because it is trashing.

> but this is not behaving in that way.
> ___________________________________________________________________
> main()
> {
>      char *x[1000];
>      int count=1000,i=0;
>      for(i=0; i <count; i++)
>           x[i] = (char*)malloc(1024*1024*10); /*10MB each time*/
> 
> }
> _______________________________________________________________________
> If i run above programm for 10 times , then system is useless for around
> 5-7minutes on PIII/128MB.

Sounds quite normal to me. If you don't enforce process limits, you
allow a normal user to thrash the system.


Erik

-- 
J.A.K. (Erik) Mouw, Information and Communication Theory Group, Department
of Electrical Engineering, Faculty of Information Technology and Systems,
Delft University of Technology, PO BOX 5031,  2600 GA Delft, The Netherlands
Phone: +31-15-2783635  Fax: +31-15-2781843  Email: J.A.K.Mouw@its.tudelft.nl
WWW: http://www-ict.its.tudelft.nl/~erik/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
