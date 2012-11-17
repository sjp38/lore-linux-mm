Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 2E3FA6B0078
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 19:18:29 -0500 (EST)
Date: Sat, 17 Nov 2012 01:18:26 +0100
From: Marc Duponcheel <marc@offline.be>
Subject: Re: [3.6 regression?] THP + migration/compaction livelock (I think)
Message-ID: <20121117001826.GC9816@offline.be>
Reply-To: Marc Duponcheel <marc@offline.be>
References: <CALCETrVgbx-8Ex1Q6YgEYv-Oxjoa1oprpsQE-Ww6iuwf7jFeGg@mail.gmail.com>
 <alpine.DEB.2.00.1211131507370.17623@chino.kir.corp.google.com>
 <CALCETrU=7+pk_rMKKuzgW1gafWfv6v7eQtVw3p8JryaTkyVQYQ@mail.gmail.com>
 <alpine.DEB.2.00.1211131530020.17623@chino.kir.corp.google.com>
 <20121114100154.GI8218@suse.de>
 <20121114132940.GA13196@offline.be>
 <alpine.DEB.2.00.1211141342460.13515@chino.kir.corp.google.com>
 <20121115011449.GA20858@offline.be>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="cWoXeonUoKmBZSoM"
Content-Disposition: inline
In-Reply-To: <20121115011449.GA20858@offline.be>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Marc Duponcheel <marc@offline.be>


--cWoXeonUoKmBZSoM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

 Hi David, others

Results seem OK

 recap: I have 2 6core 64bit opterons and I make -j13

I do

# echo always >/sys/kernel/mm/transparent_hugepage/enabled
# while [ 1 ]
  do
   sleep 10
   date
   echo = vmstat
   egrep "(thp|compact)" /proc/vmstat
   echo = khugepaged stack
   cat /proc/501/stack
 done > /tmp/49361.xxxx
# emerge icedtea
(where 501 = pidof khugepaged)

for xxxx = base = 3.6.6
and xxxx = test = 3.6.6 + diff you provided

I attach 
 /tmp/49361.base.gz
and
 /tmp/49361.test.gz

Note:

 with xxx=base, I could see
  PID USER      PR  NI  VIRT  RES  SHR S  %CPU %MEM     TIME+ COMMAND
 8617 root      20   0 3620m  41m  10m S 988.3  0.5   6:19.06 javac
    1 root      20   0  4208  588  556 S   0.0  0.0   0:03.25 init
 already during configure and I needed to kill -9 javac

 with xxx=test, I could see
  PID USER      PR  NI  VIRT  RES  SHR S  %CPU %MEM     TIME+ COMMAND
9275 root      20   0 2067m 474m  10m S 304.2  5.9   0:32.81 javac
 710 root       0 -20     0    0    0 S   0.3  0.0   0:01.07 kworker/0:1H
 later when processing >700 java files

Also note that with xxx=test compact_blocks_moved stays 0

hope this helps

 Thanks

have a nice day

On 2012 Nov 15, Marc Duponcheel wrote:
>  Hi David
> 
> Thanks for the changeset
> 
> I will test 3.6.6 without&with this weekend.
> 
>  Have a nice day

--
 Marc Duponcheel
 Velodroomstraat 74 - 2600 Berchem - Belgium
 +32 (0)478 68.10.91 - marc@offline.be

--cWoXeonUoKmBZSoM
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="49361.base.gz"
Content-Transfer-Encoding: base64

H4sICF7OplACAzQ5MzYxLmJhc2UA7dnLTttAFAbgfZ7C+y469wsq3VTddkN3VWWNx2MSxYld
2wnw9j2TC9QxEXFUECgnsED2P8eXmU8xxzeuS35U64TqhJArLq6YSr59/5kwQtnkOlkv2s51
E18taue7NCsrP2/TRbUOeaI5kVor/ri3drdhv1MZTrmVvX2L2W3jupAWblZChHJilFbsMQOH
KsuEW/U0LEYTDrGn0Mr70LaJNZNuWkNgVXYpjKt8Qv7ZUsCmzPn5bqOvytLVbegl+xv3p7Xd
19blrIO/r5P5dHUb4unnCZygn09+fSl2H0OJCrlyX38nefizCquQdq6dx0rNJ3LP3WdyX5De
AEoLXRAY8FQWkgSClOt+lAid0RitmypectrNFqFadfv8oLD39rCwyO2zpWVGdSztVl3VhDhl
6Z2bw9Sslr6bVcvdMcT5Jy+dZjxGu2kTXMxZDkHXjwll8kLEWGiWoUy34XQayjrEWyiGFwqV
lSW9yuRIYXK88OAO7j8wBCbt4DO5OWTCRzExmokjTCT88heZ9ATsmZhDJjAH5zKhY5nQMUwo
lVrFad6W2N6B9cLBRGSbKfa49D/M0he49Md8Q4xdylRnvWW2O3ZbhlDDIJ/FUfL/LGpGMuYP
FzXl3KOc15AjUQ7KQTmj5cgrMkqOFdQekaOUZuwlOZorMpRjB3IoykE571wORTkoB+WcIef0
TpgRUlvD9RE5WnGmX5ID10MHcuzgac3YoRw7kCOekyOQDtJ5Gzqnd8estFoqZZEO0kE6QOf0
7holmmvKGL1wOyazOdzcrnlIuyrN45wAnyZtH5Z+0weGGRm8WjFZwTavbQ7SnEFaYjf6w3g5
vadGKZDQlhH08tpezjoEInunyNSI9hsYoUoQoRAZIkNkY5Cd3qkDHlIaKSQiQ2SIbAyy05t6
VDIrmbb47xUiQ2SjkJ3e/oNnRS40MxyRITJENgbZiEahllowCCIyRIbIxiAb0V00mnIhpUBk
iAyRnY5Mj+kuGivgR77F46I9H5l8j8ikK1S2EQCFmxAH3rlZFCDj62I7eO1Lcn64PE3gSOA1
CFAkgAQumwBDAkjgsglwJIAELpuAQAJI4LIJSCSABC6ZgMGOEBK4MAJ/AbNhavSISQAA

--cWoXeonUoKmBZSoM
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="49361.test.gz"
Content-Transfer-Encoding: base64

H4sICEXTplACAzQ5MzYxLnRlc3QA7dg7b9swEADg3b9Ce4ceH3oZTZeia5d0KwqCkihbMG2q
EuUm/76kmzSR4wBFIZSMcZps8niiSH4QdLfSJl/MMSF5ArBO0zWF5NPnrwkFQlc3yXE/WmlX
tdn3srai0qbejWJvjqpJ4E9zLzfqcuu+2wzSKtHKTs86XVqtn/33Ac+7p7pW4+ha7LZ3nZO2
wg0w9ayldU2VrHcPjbXRWvajmkXOG58m4vvGXnfW/b5Jdttpo/yEm8TNrN6tvn1oH66CQKaa
TH78njTqx6QmJawcdz7T8A7umHwPdy3MBhDSVgW4AU9pXSS4QMLyeSjwvCI+tB+Mf2Jhu70y
k32MP0tMAdLyPDFvyoup04rkPrWcrBmU3x7xU+7cZkyH2nbm8HAP/u+TT2VOmQ+120FJH1cy
FyjnYTwrScV9mBoOSovfwWKrdK/8EvKXD+oyZyXMMsMrieH1xC9W8PFyQ9ymnV2r23ML7Gos
sMUsNE3R+C1vB6XE1liftDk9n9Dd6M9t6o9Adbafyinyyz4oraSbwWmZXDApW79JLap4Myr4
1aggBFkgi4VYpNfDokQWyGIRFtkaroYFzZEFsliIBbmeTwv8tkAWS7GgyGIxFryoysYNs8O9
sEY0frvcUR/EeH+oT4fYDcJy1NvBwRAH4kAcl3FwEjeOlKIO1BFKRxq5DgIMeSCPMDzyNUTO
g/EMeSCPUDxI9G8PSNEH+gjlg8bug6MP9BHOB4veBy/QB/oI5YNH7yPn6AN9hPIRffWqwOou
+gjlo4i+fEWBYf0KfQTzEXv9ijKO7w/0EcxH7PUrWhb4/kAfwXzEXr9iDPLlfRD0gT7+ykfs
9StOKPpAH8F8xF6/4kVJ0Af6COOjjL5+lRZ5gT7Qx3/y8Qv1soDrlEcAAA==

--cWoXeonUoKmBZSoM--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
